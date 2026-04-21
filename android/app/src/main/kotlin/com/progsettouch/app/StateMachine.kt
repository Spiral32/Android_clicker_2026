package com.progsettouch.app

import android.content.Context

/**
 * Central state machine for Prog Set Touch.
 *
 * States: IDLE, RECORDING, EXECUTING, PAUSED, ERROR
 * Any operation validates current state before execution.
 */
enum class AppState {
    IDLE,
    RECORDING,
    EXECUTING,
    PAUSED,
    ERROR,
}

/**
 * Result of state transition attempt.
 */
sealed class StateTransitionResult {
    data class Success(val newState: AppState) : StateTransitionResult()
    data class Failure(
        val currentState: AppState,
        val requestedState: AppState,
        val reason: String,
    ) : StateTransitionResult()
}

/**
 * State machine managing app lifecycle states.
 * Thread-safe for accessibility service environment.
 */
class StateMachine(
    context: Context,
) {
    private val logger = LogManager.getInstance(context)

    @Volatile
    private var currentState: AppState = AppState.IDLE

    private val lock = Any()

    private val onStateChangedListeners = mutableListOf<(AppState, AppState) -> Unit>()

    /**
     * Get current state (thread-safe read).
     */
    fun getCurrentState(): AppState = currentState

    /**
     * Attempt state transition with validation.
     *
     * Valid transitions:
     * - IDLE → RECORDING (start recording)
     * - IDLE → EXECUTING (start execution)
     * - RECORDING → IDLE (stop recording)
     * - EXECUTING → PAUSED (pause execution)
     * - EXECUTING → IDLE (stop execution)
     * - PAUSED → EXECUTING (resume execution)
     * - PAUSED → IDLE (stop execution)
     * - ANY → ERROR (on error)
     * - ERROR → IDLE (reset)
     */
    fun transition(toState: AppState): StateTransitionResult {
        val fromState: AppState
        val listenersCopy: List<(AppState, AppState) -> Unit>

        synchronized(lock) {
            fromState = currentState

            if (!isValidTransition(fromState, toState)) {
                val reason = "Invalid transition from $fromState to $toState"
                logger.w("StateMachine", reason)
                return StateTransitionResult.Failure(fromState, toState, reason)
            }

            currentState = toState
            listenersCopy = onStateChangedListeners.toList()
        }

        logger.i("StateMachine", "State transition: $fromState -> $toState")

        listenersCopy.forEach { listener ->
            try {
                listener(fromState, toState)
            } catch (e: Exception) {
                logger.e("StateMachine", "Listener error", e)
            }
        }

        return StateTransitionResult.Success(toState)
    }

    /**
     * Check if transition is valid without performing it.
     */
    fun canTransition(toState: AppState): Boolean {
        return isValidTransition(currentState, toState)
    }

    /**
     * Register listener for state changes.
     */
    fun addOnStateChangedListener(listener: (from: AppState, to: AppState) -> Unit) {
        synchronized(lock) {
            onStateChangedListeners.add(listener)
        }
    }

    /**
     * Remove state change listener.
     */
    fun removeOnStateChangedListener(listener: (from: AppState, to: AppState) -> Unit) {
        synchronized(lock) {
            onStateChangedListeners.remove(listener)
        }
    }

    /**
     * Force transition to ERROR state from any state.
     * Use for unrecoverable errors.
     */
    fun error(message: String): StateTransitionResult {
        logger.e("StateMachine", "Error state triggered: $message")
        return transition(AppState.ERROR)
    }

    /**
     * Reset from ERROR to IDLE.
     */
    fun reset(): StateTransitionResult {
        synchronized(lock) {
            if (currentState != AppState.ERROR) {
                val reason = "Can only reset from ERROR state, current: $currentState"
                logger.w("StateMachine", reason)
                return StateTransitionResult.Failure(currentState, AppState.IDLE, reason)
            }
        }

        return transition(AppState.IDLE)
    }

    /**
     * Check if recording operations are allowed.
     */
    fun canStartRecording(): Boolean =
        currentState == AppState.IDLE

    /**
     * Check if execution operations are allowed.
     */
    fun canStartExecution(): Boolean =
        currentState == AppState.IDLE

    /**
     * Check if pause/resume operations are allowed.
     */
    fun canPause(): Boolean =
        currentState == AppState.EXECUTING

    fun canResume(): Boolean =
        currentState == AppState.PAUSED

    /**
     * Get human-readable state description.
     */
    fun getStateDescription(): String = when (currentState) {
        AppState.IDLE -> "Ready"
        AppState.RECORDING -> "Recording gestures"
        AppState.EXECUTING -> "Executing scenario"
        AppState.PAUSED -> "Paused"
        AppState.ERROR -> "Error - requires reset"
    }

    private fun isValidTransition(from: AppState, to: AppState): Boolean {
        // Same state is always valid (no-op)
        if (from == to) return true

        // ERROR can be reached from any state
        if (to == AppState.ERROR) return true

        // Reset only from ERROR to IDLE
        if (from == AppState.ERROR && to == AppState.IDLE) return true
        if (from == AppState.ERROR) return false

        return when (from) {
            AppState.IDLE -> to == AppState.RECORDING || to == AppState.EXECUTING
            AppState.RECORDING -> to == AppState.IDLE
            AppState.EXECUTING -> to == AppState.PAUSED || to == AppState.IDLE
            AppState.PAUSED -> to == AppState.EXECUTING || to == AppState.IDLE
            AppState.ERROR -> false
        }
    }
}

/**
 * Extension to convert state to map for platform bridge.
 */
fun AppState.toMap(): Map<String, Any> = mapOf(
    "state" to name,
    "description" to when (this) {
        AppState.IDLE -> "Ready"
        AppState.RECORDING -> "Recording gestures"
        AppState.EXECUTING -> "Executing scenario"
        AppState.PAUSED -> "Paused"
        AppState.ERROR -> "Error - requires reset"
    },
    "canRecord" to (this == AppState.IDLE),
    "canExecute" to (this == AppState.IDLE),
    "canPause" to (this == AppState.EXECUTING),
    "canResume" to (this == AppState.PAUSED),
    "canReset" to (this == AppState.ERROR),
)
