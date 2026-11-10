#!/usr/bin/env bash
# Avisos a la Oficina de Claude Code (agente.ia-app.com). Nunca falla ni frena.
# Si la máquina ya tiene el gancho del entorno del orquestador, ese avisa: aquí no se repite.
[ -x /root/.claude/hooks/avisar-oficina.sh ] && exit 0
command -v jq >/dev/null || exit 0
entrada="$(cat 2>/dev/null)"
sid="session_${CLAUDE_CODE_REMOTE_SESSION_ID#cse_}"
cuerpo="$(printf '%s' "$entrada" | jq -c --arg sid "$sid" '{session_id: $sid,
  agent_id: (.agent_id // null), agent_type: (.agent_type // null),
  hook_event_name: (.hook_event_name // null), tool_name: (.tool_name // null),
  tool_input: (if (.tool_name == "Agent" or .tool_name == "Task")
    then {description: ((.tool_input.description // "") | .[0:120])} else null end)}' 2>/dev/null)" || exit 0
[ -n "$cuerpo" ] || exit 0
( curl -s --max-time 3 -X POST https://agente.ia-app.com/api/claude-code/actividad \
  -H "Authorization: Bearer proxy-injected" -H "Content-Type: application/json" \
  -d "$cuerpo" >/dev/null 2>&1 & )
exit 0
