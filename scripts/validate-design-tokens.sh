#!/usr/bin/env bash
# Gate de qualidade dos design tokens recebidos do cicd-create-tokens.
# Roda no CI (PR) e antes de cada deploy. Sem a pasta (antes do primeiro sync), não faz nada.
set -euo pipefail

DIR="${1:-design-tokens}"
if [ ! -d "$DIR" ]; then
  echo "Pasta $DIR ainda não existe (nenhum sync feito). Nada a validar."
  exit 0
fi

FILE="$DIR/DesignTokens.swift"
[ -f "$FILE" ] || { echo "::error::Esperado $FILE"; exit 1; }
grep -q 'public enum DesignTokens' "$FILE" || { echo "::error::enum DesignTokens ausente"; exit 1; }
if command -v swiftc >/dev/null; then
  swiftc -parse "$FILE"
  echo "OK: $(grep -c 'public static let' "$FILE") tokens, sintaxe Swift válida"
else
  echo "::warning::swiftc indisponível no runner; validação de sintaxe Swift pulada"
fi
