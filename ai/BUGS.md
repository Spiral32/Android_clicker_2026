[2026-04-12]
Issue:
Real Flutter/Android build verification was not executed.
Reason:
The environment constraints explicitly forbid CLI commands required for build and runtime validation.

[2026-04-12]
Issue:
Manual scaffolding may still require generated Flutter platform files before device deployment.
Reason:
`flutter create` could not be used under the anti-hang restrictions.
[2026-04-15]
Issue:
Fullscreen CONTINUOUS recorder blocks underlying app interaction.

Status:
Architecture-level limitation identified. No longer treated as the target production UX.

Resolution path:
- move Stage 4 to non-blocking step-by-step capture
- remap legacy `CONTINUOUS` requests to the non-blocking recording mode
- continue refining point capture UX instead of fullscreen raw pass-through recording

[2026-04-15]
Issue:
After stopping recorder from overlay controls, pressing "Open recording panel" again may fail to reopen the recorder.

Cause:
- recorder UI cleanup completed successfully
- but state machine could remain in `RECORDING`
- next start request was then blocked by state validation

Resolution:
- propagate overlay stop back into service-level state transition
- ensure `RECORDING -> IDLE` happens when stop is requested from recorder overlay

[2026-04-15]
Issue:
The point-capture recorder panel can obstruct target UI while choosing actions.

Status:
Resolved in current direction.

Resolution:
- keep the panel floating
- add a visible drag handle so the operator can move the panel away before selecting capture points
- keep the deprecated overlay status card hidden to avoid duplicate status messaging on the main screen
