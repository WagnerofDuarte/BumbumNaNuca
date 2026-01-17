# Feature Specification: Register Check-In Flow

**Feature Branch**: `005-register-check-in`  
**Created**: January 15, 2026  
**Status**: Draft  
**Input**: User description: "Register Check-In Flow with photos, training details, and calendar view for tracking check-ins"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Check-In Registration (Priority: P1)

A user completes a training session and wants to record their accomplishment by creating a check-in with essential details and a photo to track their fitness journey.

**Why this priority**: Core value proposition of the feature - enables users to capture and preserve their training moments, which is essential for motivation and progress tracking.

**Independent Test**: Can be fully tested by tapping "Check In" button, filling in required training details (exercise type, title, date/time), adding a training photo, and saving the check-in. Delivers immediate value by creating a visible record of the workout.

**Acceptance Scenarios**:

1. **Given** the user is on the Home screen, **When** they tap the "Check In" button, **Then** the Register Check-In screen opens with an empty form
2. **Given** the Register Check-In form is open, **When** the user selects an exercise type from the predefined list (Run, Gym, Swim, Bike, Walk, Yoga, Cycling, Strength Training), **Then** the selection is saved and displayed
3. **Given** the user is on the Register Check-In screen, **When** they tap "Add Photo", **Then** they see options to either open the camera or choose from the photo gallery
4. **Given** the user selects "Open Camera", **When** camera permissions are not granted, **Then** the system requests camera permissions with appropriate messaging
5. **Given** the user has captured or selected a training photo, **When** they return to the Register Check-In form, **Then** the photo is displayed in the training photo section
6. **Given** the user has filled in exercise type and title, **When** they tap the "Check In" button, **Then** the check-in is saved with current date/time as default and the user returns to the Home screen
7. **Given** a check-in was just created, **When** the user returns to the Home screen, **Then** the total check-ins count is incremented by 1

---

### User Story 2 - Detailed Training Metrics Capture (Priority: P2)

A user wants to record comprehensive details about their training session including calories burned and location to maintain detailed fitness records.

**Why this priority**: Enhances the value of check-ins by enabling users to track metrics that matter for their fitness goals, building on the core check-in capability.

**Independent Test**: Can be tested by creating a check-in and adding optional fields (calories burned, location) along with required fields. Delivers value by providing richer data for fitness tracking.

**Acceptance Scenarios**:

1. **Given** the Register Check-In form is open, **When** the user enters a numeric value in the "Calories Burned" field, **Then** the value is saved with the check-in
2. **Given** the Register Check-In form is open, **When** the user taps the Date & Time field, **Then** a date and time picker appears allowing selection of any past or present date/time
3. **Given** the user is selecting a date/time, **When** they confirm their selection, **Then** the selected date/time is displayed in the form
4. **Given** the Register Check-In form is open, **When** the user enters a location (manually), **Then** the location text is saved with the check-in
5. **Given** the user has filled all training details including optional fields, **When** they save the check-in, **Then** all details are persisted and retrievable

---

### User Story 3 - Monthly Calendar Overview (Priority: P1)

A user wants to see their training consistency at a glance by viewing their current month's check-ins displayed on a calendar with their training photos.

**Why this priority**: Visual representation of training consistency is a key motivator for fitness adherence. This provides immediate feedback on training patterns.

**Independent Test**: Can be tested by navigating to the Check-In tab and viewing the current month calendar with check-in photos displayed on the days they occurred. Delivers value by showing progress visualization.

**Acceptance Scenarios**:

1. **Given** the user has created at least one check-in, **When** they navigate to the Check-In tab, **Then** they see a summary section at the top showing total number of check-ins
2. **Given** the user is viewing the Check-In tab, **When** they scroll to the calendar section, **Then** they see the current month's calendar
3. **Given** a user has check-ins on specific days in the current month, **When** they view the monthly calendar, **Then** each day with a check-in displays the training photo as a rounded image inside the calendar day cell
4. **Given** a day has multiple check-ins, **When** viewing the calendar, **Then** the most recent check-in photo for that day is displayed

---

### User Story 4 - Historical Check-In Calendar Navigation (Priority: P2)

A user wants to review their complete training history by browsing through all months in which they have recorded check-ins.

**Why this priority**: Supports long-term engagement by allowing users to reflect on their fitness journey over time, building on the monthly calendar view.

**Independent Test**: Can be tested by tapping "View All Check-ins" button and scrolling through multiple months of calendar views. Delivers value by providing complete historical perspective.

**Acceptance Scenarios**:

1. **Given** the user is viewing the Check-In tab, **When** they tap the "View All Check-Ins" button below the calendar, **Then** the View All Check-Ins screen opens
2. **Given** the user is on the View All Check-Ins screen, **When** the screen loads, **Then** they see a vertical list of monthly calendars for all months containing at least one check-in
3. **Given** the user has check-ins spanning multiple months, **When** viewing the All Check-Ins screen, **Then** the calendars are ordered with the current month at the top and the earliest month at the bottom
4. **Given** the user is viewing a historical month calendar, **When** they look at days with check-ins, **Then** they see the rounded training photos displayed for each check-in day
5. **Given** the user has no check-ins in a particular month, **When** viewing the All Check-Ins screen, **Then** that month is not displayed in the list

---

### Edge Cases

- What happens when the user tries to save a check-in without selecting an exercise type or entering a title? System blocks save and displays validation error
- What happens when the user saves a check-in without adding a photo? System saves successfully with exercise type icon placeholder shown in calendar
- What happens when camera or photo gallery permissions are denied?
- How does the system handle very large photos or corrupted image files?
- What happens when the user tries to select a future date for a check-in?
- How does the calendar display days with check-ins if the photo fails to load?
- What happens when a user has check-ins for the same day but different times?
- How does the system handle extremely long exercise titles or location names?
- What happens when the user navigates away from the Register Check-In screen before saving (data loss prevention)?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a "Check In" button on the Home screen that opens the Register Check-In screen
- **FR-002**: System MUST allow users to optionally add a training photo via camera or photo gallery selection
- **FR-003**: System MUST request and handle camera permissions appropriately when user attempts to take a photo
- **FR-004**: System MUST request and handle photo library permissions appropriately when user attempts to select from gallery
- **FR-005**: System MUST provide a predefined list of exercise types including Run, Gym, Swim, Bike, Walk, Yoga, Cycling, and Strength Training (no custom types in this iteration)
- **FR-006**: System MUST allow users to select one exercise type from the predefined list
- **FR-007**: System MUST provide a numeric input field for calories burned
- **FR-008**: System MUST provide a text input field for exercise title with a maximum character limit of 100 characters
- **FR-009**: System MUST provide a date and time picker for selecting check-in date and time
- **FR-010**: System MUST default the date and time picker to the current date and time
- **FR-011**: System MUST prevent users from selecting future dates for check-ins
- **FR-012**: System MUST provide an optional location input field that accepts manual text entry with a maximum character limit of 200 characters
- **FR-013**: System MUST validate that exercise type and title are provided before allowing save, and display clear error messages for missing required fields
- **FR-014**: System MUST save the check-in with all provided details when the user taps "Check In"
- **FR-015**: System MUST navigate user back to Home screen after successfully saving a check-in
- **FR-016**: System MUST display total number of check-ins in the Check-In tab summary section
- **FR-017**: System MUST display a monthly calendar view for the current month in the Check-In tab
- **FR-018**: System MUST display check-in training photos as rounded images on calendar days where check-ins exist, or display an exercise type icon placeholder when no photo is available
- **FR-019**: System MUST render placeholder icons as rounded shapes with 40-48pt size and distinct colors per exercise type
- **FR-020**: System MUST show only the most recent photo when multiple check-ins exist for the same day
- **FR-021**: System MUST provide a "View All Check-Ins" button below the monthly calendar
- **FR-022**: System MUST display all months containing check-ins in the View All Check-Ins screen
- **FR-023**: System MUST order months from current (top) to earliest (bottom) in the View All Check-Ins screen
- **FR-024**: System MUST exclude months without check-ins from the View All Check-Ins screen
- **FR-025**: System MUST persist check-in data including photo, exercise type, calories, title, date/time, and location
- **FR-026**: System MUST handle image storage efficiently to prevent excessive storage consumption
- **FR-027**: System MUST display appropriate error messages when permissions are denied (camera and photo library)
- **FR-028**: System MUST warn users before discarding unsaved check-in data if they navigate away

### Key Entities

- **Check-In**: Represents a single training session record containing exercise type, title, date/time, optional calories burned, optional location, and a training photo. Related to the user's training history and displayed in calendar views.
- **Exercise Type**: Represents predefined categories of physical activities (Run, Gym, Swim, Bike, Walk, Yoga, Cycling, Strength Training) that users can select when registering a check-in. Custom types are not supported in this iteration.
- **Training Photo**: Image captured or selected by the user to visually document their training session, associated with a specific check-in.
- **Calendar Day**: Represents a single day in a monthly calendar view that may contain one or more check-ins, displaying the most recent check-in photo.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete check-in registration from tapping "Check In" to successful save in under 90 seconds
- **SC-002**: 95% of users successfully add a training photo on their first attempt
- **SC-003**: Users can view their current month's check-in calendar within 2 seconds of navigating to the Check-In tab
- **SC-004**: System handles photo uploads and displays calendar views for users with 100+ check-ins without performance degradation
- **SC-005**: 90% of users successfully navigate to and view their complete check-in history on first attempt
- **SC-006**: Check-in photos display correctly in calendar views for all standard image formats (JPEG, PNG, HEIC)
- **SC-007**: Users can scroll through 12 months of check-in history smoothly without lag or freezing
- **SC-008**: System accurately displays total check-in count with real-time updates after new check-ins

## Clarifications

### Session 2026-01-15

- Q: Is the training photo required or optional when saving a check-in? → A: Photo is optional - user can save check-in without photo, calendar shows icon placeholder
- Q: How should total accumulated training duration be calculated? → A: Remover métrica de duração
- Q: What size and style should placeholder icons have for check-ins without photos? → A: Ícones arredondados tamanho médio (40-48pt) com cores por tipo
- Q: What should happen when user tries to save without providing a title? → A: Título sempre obrigatório
- Q: Should users be able to create custom exercise types or only use predefined ones? → A: Apenas 8 tipos predefinidos fixos (Run, Gym, Swim, Bike, Walk, Yoga, Cycling, Strength Training) - sem customização no MVP

## Assumptions

- Users will primarily take photos immediately after training when the moment is fresh
- Standard exercise types (Run, Gym, Swim, Bike, Walk, Yoga, Cycling, Strength Training) cover majority of user activities; custom types can be added in future iterations if needed
- Users prefer visual calendar representation over list-based check-in history
- Mobile device storage capacity is sufficient for storing compressed training photos (1-2 MB per photo estimated)
- Users will grant necessary permissions (camera, photo library) to fully utilize the feature
- Check-ins are personal records and do not require sharing or social features in this iteration
- Rounding training photos into circular/rounded shapes improves visual consistency in calendar view
