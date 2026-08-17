#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CHECK_ONLY=0
VALIDATION_ERRORS=0
READINESS_CONFLICTS=0
PENDING_ITEMS=0
SECURITY_WARNINGS=0
SKILL_COUNT=0
SKILL_NAMES=()
SKILL_DIRS=()
SEEN_SKILL_NAMES='|'

usage() {
  cat <<'EOF'
Usage: ./setup.sh [--check]

  (no option)  Validate the workspace, create .env when absent, and expose
               canonical skills through repo-local discovery paths.
  --check      Inspect validation and readiness without changing any files.
EOF
}

info() {
  printf '[setup] %s\n' "$1"
}

security_warning() {
  SECURITY_WARNINGS=$((SECURITY_WARNINGS + 1))
  printf '[warning] %s\n' "$1" >&2
}

pending() {
  PENDING_ITEMS=$((PENDING_ITEMS + 1))
  printf '[pending] %s\n' "$1"
}

validation_error() {
  VALIDATION_ERRORS=$((VALIDATION_ERRORS + 1))
  printf '[error] %s\n' "$1" >&2
}

readiness_conflict() {
  READINESS_CONFLICTS=$((READINESS_CONFLICTS + 1))
  printf '[conflict] %s\n' "$1" >&2
}

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

file_mode() {
  local file="$1"
  local mode

  if mode="$(stat -L -f '%Lp' "$file" 2>/dev/null)"; then
    printf '%s\n' "$mode"
  else
    stat -L -c '%a' "$file" 2>/dev/null
  fi
}

env_has_populated_values() {
  local env_file="$1"

  awk '
    /^[[:space:]]*($|#)/ { next }
    /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/ {
      value = $0
      sub(/^[^=]*=[[:space:]]*/, "", value)
      sub(/[[:space:]]*$/, "", value)
      if (value != "" && value != "\"\"" && value != "\047\047") found = 1
    }
    END { exit(found ? 0 : 1) }
  ' "$env_file"
}

warn_if_env_permissions_are_unsafe() {
  local env_file="$1"
  local mode

  env_has_populated_values "$env_file" || return 0

  mode="$(file_mode "$env_file" || true)"
  if [ -z "$mode" ]; then
    security_warning ".env is populated, but its permissions could not be inspected. Verify that only its owner can read or write it. This warning does not fail the bootstrap check."
    return
  fi

  case "$mode" in
    *00) ;;
    *)
      security_warning ".env is populated and has mode $mode, which allows group or other access. Run 'chmod 600 .env'. This warning does not fail the bootstrap check."
      ;;
  esac
}

is_current_skill_name() {
  local candidate_name="$1"
  local index=0

  while [ "$index" -lt "$SKILL_COUNT" ]; do
    if [ "${SKILL_NAMES[$index]}" = "$candidate_name" ]; then
      return 0
    fi
    index=$((index + 1))
  done
  return 1
}

frontmatter_value() {
  local file="$1"
  local key="$2"

  awk -v wanted="$key" '
    NR == 1 {
      if ($0 != "---") exit
      in_frontmatter = 1
      next
    }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && $0 ~ "^[[:space:]]*" wanted ":[[:space:]]*" {
      line = $0
      sub("^[[:space:]]*" wanted ":[[:space:]]*", "", line)
      sub(/[[:space:]]+$/, "", line)
      if ((substr(line, 1, 1) == "\"" && substr(line, length(line), 1) == "\"") ||
          (substr(line, 1, 1) == "\047" && substr(line, length(line), 1) == "\047")) {
        line = substr(line, 2, length(line) - 2)
      }
      print line
      exit
    }
  ' "$file"
}

validate_skill() {
  local skill_file="$1"
  local skill_dir
  local folder_name
  local declared_name
  local description
  local closing_line
  local metadata_file
  local expected_invocation
  local unexpected_keys

  skill_dir="$(dirname "$skill_file")"
  folder_name="$(basename "$skill_dir")"
  metadata_file="$skill_dir/agents/openai.yaml"

  if [ "$(sed -n '1p' "$skill_file")" != '---' ]; then
    validation_error "${skill_file#$ROOT_DIR/}: frontmatter must start on line 1."
    return
  fi

  closing_line="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$skill_file")"
  if [ -z "$closing_line" ]; then
    validation_error "${skill_file#$ROOT_DIR/}: frontmatter is not closed."
    return
  fi

  unexpected_keys="$(awk '
    NR == 1 { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && match($0, /^[A-Za-z0-9_-]+:/) {
      key = substr($0, 1, RLENGTH - 1)
      if (key != "name" && key != "description") print key
    }
  ' "$skill_file")"
  if [ -n "$unexpected_keys" ]; then
    validation_error "${skill_file#$ROOT_DIR/}: frontmatter may contain only name and description; found $(printf '%s' "$unexpected_keys" | tr '\n' ' ')."
  fi

  declared_name="$(frontmatter_value "$skill_file" name)"
  description="$(frontmatter_value "$skill_file" description)"

  if [ -z "$declared_name" ]; then
    validation_error "${skill_file#$ROOT_DIR/}: frontmatter requires a non-empty name."
  elif [ "$declared_name" != "$folder_name" ]; then
    validation_error "${skill_file#$ROOT_DIR/}: name '$declared_name' must match folder '$folder_name'."
  elif ! printf '%s\n' "$declared_name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    validation_error "${skill_file#$ROOT_DIR/}: name must use lowercase kebab-case."
  fi

  if [ -z "$description" ]; then
    validation_error "${skill_file#$ROOT_DIR/}: frontmatter requires a non-empty description."
  fi

  if [ -n "$declared_name" ]; then
    case "$SEEN_SKILL_NAMES" in
      *"|$declared_name|"*)
        validation_error "Duplicate skill name '$declared_name'; discovery paths require unique names."
        ;;
      *)
        SKILL_NAMES+=("$declared_name")
        SKILL_DIRS+=("$skill_dir")
        SEEN_SKILL_NAMES="${SEEN_SKILL_NAMES}${declared_name}|"
        SKILL_COUNT=$((SKILL_COUNT + 1))
        ;;
    esac
  fi

  if [ ! -f "$metadata_file" ]; then
    validation_error "${metadata_file#$ROOT_DIR/}: required metadata file is missing."
    return
  fi

  if ! grep -Eq '^[[:space:]]*interface:[[:space:]]*$' "$metadata_file"; then
    validation_error "${metadata_file#$ROOT_DIR/}: interface metadata is missing."
  fi

  if ! grep -Eq '^[[:space:]]*display_name:[[:space:]]*[^[:space:]]' "$metadata_file"; then
    validation_error "${metadata_file#$ROOT_DIR/}: display_name must be non-empty."
  fi

  if ! grep -Eq '^[[:space:]]*short_description:[[:space:]]*[^[:space:]]' "$metadata_file"; then
    validation_error "${metadata_file#$ROOT_DIR/}: short_description must be non-empty."
  fi

  if ! grep -Eq '^[[:space:]]*default_prompt:[[:space:]]*[^[:space:]]' "$metadata_file"; then
    validation_error "${metadata_file#$ROOT_DIR/}: default_prompt must be non-empty."
  elif [ -n "$declared_name" ]; then
    expected_invocation="\$$declared_name"
    if ! grep -Fq -- "$expected_invocation" "$metadata_file"; then
      validation_error "${metadata_file#$ROOT_DIR/}: default_prompt must mention '$expected_invocation'."
    fi
  fi
}

link_points_to() {
  local link_path="$1"
  local canonical_dir="$2"
  local raw_target
  local link_parent
  local resolved_target
  local resolved_canonical

  [ -L "$link_path" ] || return 1
  raw_target="$(readlink "$link_path")"
  link_parent="$(dirname "$link_path")"

  case "$raw_target" in
    /*) resolved_target="$raw_target" ;;
    *) resolved_target="$link_parent/$raw_target" ;;
  esac

  [ -d "$resolved_target" ] || return 1
  resolved_target="$(cd "$resolved_target" && pwd -P)"
  resolved_canonical="$(cd "$canonical_dir" && pwd -P)"
  [ "$resolved_target" = "$resolved_canonical" ]
}

inspect_discovery_root() {
  local discovery_root="$1"
  local runtime_root
  local index
  local link_path
  local existing_path
  local existing_name
  local raw_target

  runtime_root="$(dirname "$discovery_root")"
  if [ -L "$runtime_root" ]; then
    readiness_conflict "${runtime_root#$ROOT_DIR/} is a symlink; refusing to write through it."
    return
  fi

  if path_exists "$runtime_root" && [ ! -d "$runtime_root" ]; then
    readiness_conflict "${runtime_root#$ROOT_DIR/} exists but is not a directory."
    return
  fi

  if [ -L "$discovery_root" ]; then
    readiness_conflict "${discovery_root#$ROOT_DIR/} is a symlink; refusing to write through it."
    return
  fi

  if path_exists "$discovery_root" && [ ! -d "$discovery_root" ]; then
    readiness_conflict "${discovery_root#$ROOT_DIR/} exists but is not a directory."
    return
  fi

  if [ ! -d "$discovery_root" ]; then
    pending "${discovery_root#$ROOT_DIR/} will be created."
    return
  fi

  index=0
  while [ "$index" -lt "$SKILL_COUNT" ]; do
    link_path="$discovery_root/${SKILL_NAMES[$index]}"
    if ! path_exists "$link_path"; then
      pending "${link_path#$ROOT_DIR/} is not exposed yet."
    elif ! link_points_to "$link_path" "${SKILL_DIRS[$index]}"; then
      readiness_conflict "${link_path#$ROOT_DIR/} already exists and does not point to the canonical skill."
    fi
    index=$((index + 1))
  done


  for existing_path in "$discovery_root"/*; do
    path_exists "$existing_path" || continue
    existing_name="$(basename "$existing_path")"
    is_current_skill_name "$existing_name" && continue
    if [ -L "$existing_path" ]; then
      raw_target="$(readlink "$existing_path")"
      case "$raw_target" in
        ../../skills/*) pending "${existing_path#$ROOT_DIR/} is a stale generated skill link and will be removed." ;;
      esac
    fi
  done
}

create_discovery_links() {
  local discovery_root="$1"
  local index
  local link_path
  local relative_target
  local existing_path
  local existing_name
  local raw_target

  mkdir -p "$discovery_root"

  for existing_path in "$discovery_root"/*; do
    path_exists "$existing_path" || continue
    existing_name="$(basename "$existing_path")"
    is_current_skill_name "$existing_name" && continue
    if [ -L "$existing_path" ]; then
      raw_target="$(readlink "$existing_path")"
      case "$raw_target" in
        ../../skills/*)
          rm "$existing_path"
          info "Removed stale generated link ${existing_path#$ROOT_DIR/}."
          ;;
      esac
    fi
  done

  index=0
  while [ "$index" -lt "$SKILL_COUNT" ]; do
    link_path="$discovery_root/${SKILL_NAMES[$index]}"
    relative_target="../../${SKILL_DIRS[$index]#$ROOT_DIR/}"
    if ! path_exists "$link_path"; then
      ln -s "$relative_target" "$link_path"
      info "Exposed ${SKILL_NAMES[$index]} at ${link_path#$ROOT_DIR/}."
    fi
    index=$((index + 1))
  done
}

if [ "$#" -gt 1 ]; then
  usage >&2
  exit 2
fi

if [ "$#" -eq 1 ]; then
  case "$1" in
    --check) CHECK_ONLY=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
fi

cd "$ROOT_DIR"
info "Validating workspace at $ROOT_DIR"

required_files=(
  README.md
  AGENTS.md
  CLAUDE.md
  SETUP.md
  context.md
  task.md
  log.md
  index.md
  COMPATIBILITY.md
  CONTRIBUTING.md
  VERSION
  setup.sh
  .gitignore
  .env.example
  projects/_template/project.md
)

for required_file in "${required_files[@]}"; do
  if [ ! -f "$ROOT_DIR/$required_file" ]; then
    validation_error "$required_file is required."
  fi
done

if [ -f "$ROOT_DIR/VERSION" ] && ! grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' "$ROOT_DIR/VERSION"; then
  validation_error "VERSION must contain one semantic version such as 0.2.0."
fi

if [ ! -d "$ROOT_DIR/skills" ]; then
  validation_error "skills/ is required."
else
  while IFS= read -r skill_file; do
    validate_skill "$skill_file"
  done < <(find "$ROOT_DIR/skills" -type f -name SKILL.md -print | LC_ALL=C sort)

  if [ "$SKILL_COUNT" -eq 0 ]; then
    validation_error "No skills/**/SKILL.md packages were found."
  fi
fi

if [ "$VALIDATION_ERRORS" -gt 0 ]; then
  printf '[failed] %s validation error(s); no setup changes were made.\n' "$VALIDATION_ERRORS" >&2
  exit 1
fi

info "Validated $SKILL_COUNT skill package(s)."

if ! path_exists "$ROOT_DIR/.env"; then
  pending ".env will be created from .env.example without secret values."
elif [ -d "$ROOT_DIR/.env" ]; then
  readiness_conflict ".env exists but is a directory; expected a file or file symlink."
else
  info ".env already exists; it will not be changed."
  warn_if_env_permissions_are_unsafe "$ROOT_DIR/.env"
fi

inspect_discovery_root "$ROOT_DIR/.agents/skills"
inspect_discovery_root "$ROOT_DIR/.claude/skills"

if [ "$READINESS_CONFLICTS" -gt 0 ]; then
  printf '[failed] %s conflicting path(s); nothing was overwritten.\n' "$READINESS_CONFLICTS" >&2
  exit 1
fi

if [ "$CHECK_ONLY" -eq 1 ]; then
  if [ "$PENDING_ITEMS" -eq 0 ]; then
    info "Bootstrap/discovery check passed; canonical skills are exposed."
  else
    info "Bootstrap validation passed with $PENDING_ITEMS pending setup item(s). Run ./setup.sh to configure them."
  fi
  if [ "$SECURITY_WARNINGS" -gt 0 ]; then
    info "Bootstrap check completed with $SECURITY_WARNINGS security warning(s); warnings are advisory and do not change the exit status."
  fi
  info "Product/source readiness was not evaluated. Use \$configure-workspace after connecting your sources."
else
  if ! path_exists "$ROOT_DIR/.env"; then
    (
      umask 077
      cp -n "$ROOT_DIR/.env.example" "$ROOT_DIR/.env"
    )
    if [ -f "$ROOT_DIR/.env" ]; then
      info "Created .env from .env.example with owner-only permissions. Add secrets locally; never commit them."
    else
      readiness_conflict ".env appeared during setup and was not overwritten. Re-run ./setup.sh after inspecting it."
      exit 1
    fi
  fi

  create_discovery_links "$ROOT_DIR/.agents/skills"
  create_discovery_links "$ROOT_DIR/.claude/skills"
  info "Bootstrap/discovery setup complete. Re-run ./setup.sh --check at any time."
  info "Product/source readiness was not evaluated. Use \$configure-workspace after connecting your sources."
fi

cat <<EOF
[manual] Other or custom CLIs should load root instructions from:
         $ROOT_DIR/AGENTS.md
         and discover each package below:
         $ROOT_DIR/skills
         Keep skills/ canonical; do not copy provider-specific variants.
EOF
