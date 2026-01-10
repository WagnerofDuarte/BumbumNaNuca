# Feature Specification: Exercise Execution Refinement

**Feature Branch**: `004-exercise-execution-refinement`  
**Created**: 2026-01-10  
**Status**: Draft  
**Input**: User description: "Refactor exercise execution flow with rest timer, add load input to exercises, and fix workout completion navigation"

## Clarifications

### Session 2026-01-10

- Q: Como o sistema deve rastrear as repetições realmente executadas? → A: Assumir automaticamente que o usuário completou todas as repetições planejadas (sem entrada manual)
- Q: Como o timer deve se comportar quando o app vai para background? → A: Continuar rodando em background e tocar um som/notificação quando terminar
- Q: Qual deve ser o tempo padrão de descanso quando não configurado? → A: 60 segundos (1 minuto - descanso curto, ideal para circuitos e resistência muscular)
- Q: Como tratar a finalização quando nem todas as séries foram completadas? → A: Exibir confirmação informando quantas séries faltam e pedir confirmação
- Q: Como o sistema deve determinar quando avançar para a próxima série? → A: Pressionar "Começar Descanso" completa a série atual e incrementa automaticamente

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Streamlined Exercise Execution with Rest Timer (Priority: P1)

During a workout session, the user needs a focused, distraction-free way to complete each exercise set with proper rest intervals between sets. The interface should guide them through each set, automatically manage rest timing, and clearly indicate when to move to the next set or finish the exercise.

**Why this priority**: This is the core workout execution experience. Without a smooth, intuitive flow for completing sets and resting between them, users will struggle to maintain proper training form and adherence. This directly impacts user satisfaction and app retention.

**Independent Test**: Can be fully tested by starting a workout, selecting any exercise, completing all sets with rest periods, and verifying the flow is clear and non-disruptive. Delivers a complete exercise execution experience that can be shipped independently.

**Acceptance Scenarios**:

1. **Given** a user has an active workout session, **When** they select any exercise from the workout list, **Then** they should see the exercise series screen with exercise details at the top and a "Começar Descanso" button at the bottom
2. **Given** the user is on the exercise series screen, **When** they press the "Começar Descanso" button, **Then** a countdown timer should appear in the middle of the screen showing the exercise's configured rest time
3. **Given** the user presses "Começar Descanso", **When** the action completes, **Then** the current set should be marked as complete and the set counter should increment to the next set
4. **Given** the rest timer is running, **When** the countdown reaches zero, **Then** the timer should reset to the initial rest time and stop automatically
5. **Given** the rest timer has stopped, **When** the user presses "Começar Descanso" again, **Then** the timer should restart from the configured rest time
6. **Given** the user is on the last set of an exercise, **When** they view the exercise series screen, **Then** the button should display "Finalizar Exercício" instead of "Começar Descanso"
7. **Given** the user is on the last set, **When** they press "Finalizar Exercício", **Then** the exercise should be marked complete and they should return to the workout session screen
8. **Given** the user is viewing the exercise series screen, **When** they look at the top of the screen, **Then** they should see all relevant exercise information (name, target muscle group, sets, reps, rest time)

---

### User Story 2 - Exercise Load Tracking (Priority: P2)

When creating or configuring an exercise, users need to specify the load (weight) they plan to use, measured in kilograms. This allows them to track progressive overload and ensure consistency across workout sessions.

**Why this priority**: Load tracking is essential for strength training progression, but it's a configuration feature rather than core execution flow. It can be added after the execution flow is working, making it P2.

**Independent Test**: Can be fully tested by navigating to the exercise creation/configuration screen, entering a load value in Kg, and verifying it's saved and displayed correctly. Delivers value independently by enabling load tracking.

**Acceptance Scenarios**:

1. **Given** a user is creating a new exercise, **When** they access the exercise configuration screen, **Then** they should see a field to input the load in Kg
2. **Given** a user is editing an existing exercise, **When** they access the exercise configuration screen, **Then** they should see the current load value and be able to modify it
3. **Given** a user enters a load value, **When** they save the exercise, **Then** the load should be persisted with the exercise configuration
4. **Given** a user has configured an exercise load, **When** they view the exercise during workout execution, **Then** the configured load should be displayed in the exercise information

---

### User Story 3 - Correct Workout Completion Navigation (Priority: P1)

After completing all exercises in a workout session, when the user views the completion summary and presses "Finalizar", they should be returned to the home screen, not back to the active workout session screen. This provides closure and prevents confusion about the session state.

**Why this priority**: This is a critical bug that breaks the user's mental model of workflow completion. Having it redirect back to the active session after "finishing" creates confusion and frustration. High priority because it's a breaking experience issue.

**Independent Test**: Can be fully tested by completing a workout session, pressing "Finalizar" on the completion screen, and verifying navigation goes to home. Delivers a complete and correct workflow conclusion.

**Acceptance Scenarios**:

1. **Given** a user has completed all exercises in a workout session, **When** they view the "Treino Concluído" screen, **Then** they should see a "Finalizar" button
2. **Given** a user is on the "Treino Concluído" screen, **When** they press "Finalizar", **Then** they should be navigated to the Home screen
3. **Given** a user presses "Finalizar" on the completion screen, **When** the navigation completes, **Then** the workout session should be marked as ended and no longer active
4. **Given** a user has finished a workout and returned to Home, **When** they check their workout history or stats, **Then** the completed session should be recorded with all exercise data

---

### Edge Cases

- What happens when the user manually enters sets/reps data on the refactored exercise series screen (should not be possible - forms removed)?
- What happens when a user backgrounds the app while the rest timer is running (timer continues and notifies when complete)?
- What happens when a user tries to navigate away from the exercise screen while on the last set?
- What happens when an exercise has no configured rest time (default to 60 seconds)?
- What happens when a user presses "Finalizar Exercício" but hasn't completed all sets (show confirmation dialog with remaining sets count and allow if confirmed)?
- What happens when a user creates an exercise without specifying a load (allow zero/empty load as optional)?
- What happens when the rest timer is running and the user rotates the device or the screen locks?

## Requirements *(mandatory)*

### Functional Requirements

**Exercise Series Screen Refactor**:
- **FR-001**: System MUST remove all input forms for repetitions and load from the exercise series screen during workout execution
- **FR-002**: System MUST display complete exercise information at the top of the exercise series screen (exercise name, target muscle group, number of sets, number of reps, rest time, load)
- **FR-003**: System MUST display a "Começar Descanso" button at the bottom of the exercise series screen for all sets except the last set
- **FR-004**: System MUST display a "Finalizar Exercício" button at the bottom of the exercise series screen when the user is on the last set

**Rest Timer Functionality**:
- **FR-005**: System MUST initiate a countdown timer when the user presses "Começar Descanso"
- **FR-006**: Timer MUST be displayed in the middle of the exercise series screen, showing remaining time in a clear format
- **FR-007**: Timer MUST count down from the exercise's configured rest time to zero
- **FR-007A**: System MUST use a default rest time of 60 seconds when an exercise has no configured rest time
- **FR-008**: Timer MUST automatically stop and reset to the initial rest time when countdown reaches zero
- **FR-009**: System MUST allow the user to press "Começar Descanso" again to restart the timer from the configured rest time
- **FR-010**: Timer MUST continue running in background when the user backgrounds the app
- **FR-010A**: System MUST emit an audible sound or notification when the timer completes while the app is in background
- **FR-010B**: Timer MUST display the correct remaining time when the user returns to the app from background

**Exercise Completion**:
- **FR-011**: System MUST mark the exercise as complete when the user presses "Finalizar Exercício" on the last set
- **FR-011A**: System MUST display a confirmation dialog when the user attempts to finish an exercise before completing all planned sets, informing how many sets remain and requesting confirmation
- **FR-011B**: System MUST allow the user to proceed with finishing the exercise even if not all sets are completed, after confirmation
- **FR-012**: System MUST navigate the user back to the workout session screen after pressing "Finalizar Exercício"
- **FR-013**: System MUST track which set the user is currently on within an exercise
- **FR-013A**: System MUST automatically record the planned number of repetitions as the actual repetitions performed when the user completes a set (presses "Começar Descanso" or "Finalizar Exercício")
- **FR-013B**: System MUST automatically record the configured exercise load as the actual load used when the user completes a set
- **FR-013C**: System MUST increment the current set counter when the user presses "Começar Descanso", marking the current set as complete
- **FR-013D**: System MUST display the updated set number (next set) after the user presses "Começar Descanso" and the counter increments

**Exercise Load Configuration**:
- **FR-014**: System MUST provide an input field for exercise load (in Kg) on the exercise creation/configuration screen
- **FR-015**: System MUST persist the load value with the exercise configuration
- **FR-016**: System MUST display the configured load value on the exercise series screen during workout execution
- **FR-017**: System MUST allow the load field to be optional (users can create exercises without specifying load)

**Workout Completion Navigation**:
- **FR-018**: System MUST navigate to the Home screen when the user presses "Finalizar" on the "Treino Concluído" screen
- **FR-019**: System MUST mark the workout session as ended when the user completes the workout and presses "Finalizar"
- **FR-020**: System MUST prevent navigation back to the active workout session screen after the session has been marked as ended

### Key Entities

- **Exercise**: Represents a specific exercise with attributes including name, target muscle group, configured number of sets, configured number of reps, rest time between sets, and load (in Kg)
- **Exercise Set**: Represents a single set within an exercise, tracking set number, actual reps performed (automatically copied from planned reps when set is completed), actual load used (automatically copied from configured load when set is completed), and completion status
- **Workout Session**: Represents an active or completed workout, containing a list of exercises, overall session state (active/completed), start time, and end time
- **Rest Timer**: Represents the countdown timer state for rest periods, including configured duration, remaining time, and running/stopped state

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete an entire exercise (all sets with rest periods) without needing to manually enter data during execution
- **SC-002**: Rest timer countdown completes within 1 second accuracy of the configured rest time (e.g., 60-second rest completes in 59-61 seconds)
- **SC-003**: Users can navigate from workout completion to home screen in a single button press without seeing the active session screen
- **SC-004**: 100% of exercise configurations can include an optional load value stored in Kg
- **SC-005**: Users can identify which set they are on and whether it's the last set within 2 seconds of viewing the exercise screen
- **SC-006**: The refactored exercise execution flow reduces time spent on data entry during workouts by at least 50% compared to the previous implementation
