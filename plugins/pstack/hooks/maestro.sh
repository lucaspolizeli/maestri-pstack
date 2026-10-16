# Sourced by the hooks. True when this terminal is the Maestro, so it can recruit.
# `maestri list` works from any terminal and prints "maestro: true" under "You:".
is_maestro() {
  "${MAESTRI_CLI:-maestri}" list 2>/dev/null | sed -n '/^You:/{n;p;q;}' | grep -q 'maestro: true'
}
