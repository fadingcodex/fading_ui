# Fading UI widget roadmap

## Status overview

| Widget | Status | Notes |
|---|---|---|
| FadingAccordion | Implemented ✅ | Expand/collapse sections with animation. |
| FadingButton | Implemented ✅ | Primary action/button variants. |
| FadingCard | Implemented ✅ | Content container/surface card. |
| FadingCheckbox | Implemented ✅ | Boolean form control. |
| FadingChips | Implemented ✅ | Selectable/filter chip patterns. |
| FadingDataTable | Implemented ✅ | Sortable table and row states. |
| FadingDatePicker | Implemented ✅ | Calendar-style date selection. |
| FadingModal | Implemented ✅ | Reusable dialog shell. |
| FadingPagination | Implemented ✅ | Page controls for list/table views. |
| FadingProgressIndicator | Implemented ✅ | Progress/loading indicators. |
| FadingRadioGroup | Implemented ✅ | Single-select option groups. |
| FadingSelect | Implemented ✅ | OverlayEntry-based custom select. |
| FadingSlider | Implemented ✅ | Single value slider control. |
| FadingSnackbar | Implemented ✅ | Bottom notification with action. |
| FadingSurface | Implemented ✅ | Shared elevated/inset container primitive. |
| FadingSwitch | Implemented ✅ | Toggle control. |
| FadingTabBar | Implemented ✅ | Segmented navigation tabs. |
| FadingTextField | Implemented ✅ | Text input control. |
| FadingTimePicker | Implemented ✅ | Time selection control. |
| FadingToast | Implemented ✅ | Lightweight transient message. |
| FadingTooltip | Considering ❓ | Hover/focus/long-press contextual label. |
| FadingStepper | To-do 🛠️ | Multi-step progress flow (horizontal/vertical). |
| FadingSegmentedControl | To-do 🛠️ | Compact option switcher for cards/toolbars. |
| FadingBottomSheet | To-do 🛠️ | Partial-height action/content panel. |
| FadingDrawer | To-do 🛠️ | Side navigation and quick actions. |
| FadingMenu | To-do 🛠️ | Anchored contextual menu and action list. |
| FadingBreadcrumbs | Implemented ✅ | Hierarchical path navigation. |
| FadingBadge | Implemented ✅ | Compact tone-based status label for badges and counts. |
| FadingAutocomplete | To-do 🛠️ | Type-ahead text suggestions. |
| FadingMultiSelect | To-do 🛠️ | Multi-select dropdown/list input. |
| FadingRangeSlider | To-do 🛠️ | Min/max range selection. |
| FadingFieldGroup | To-do 🛠️ | Labeled/validated form field grouping. |
| FadingOTPField | To-do 🛠️ | Multi-cell one-time code input. |
| FadingSkeleton | To-do 🛠️ | Loading placeholders for content. |
| FadingEmptyState | To-do 🛠️ | Empty/no-data UX pattern. |
| FadingTimeline | To-do 🛠️ | Ordered event/activity display. |
| FadingStatCard | To-do 🛠️ | KPI card with trend and metadata. |
| FadingInlineBanner | To-do 🛠️ | Inline page-level message/alert block. |
| FadingAppBar | To-do 🛠️ | Consistent top navigation/title bar. |
| FadingPageScaffold | To-do 🛠️ | Standardized page shell/layout slots. |
| FadingSplitPane | To-do 🛠️ | Resizable two-pane layout. |
| FadingResponsiveGrid | To-do 🛠️ | Breakpoint-aware grid layout. |
| FadingSection | To-do 🛠️ | Section title + body + actions wrapper. |

## Implemented widgets (past milestones)

### Core surfaces and actions

#### FadingSurface
Shared container primitive for elevated and inset surfaces.
Acts as a visual foundation for cards, panels, and grouped controls.

#### FadingCard
Content card wrapper for grouped information and actions.
Provides a consistent panel style aligned with theme tokens.

#### FadingButton
Primary action control used across forms, dialogs, and toolbars.
Supports consistent interaction states through the Fading design language.

### Form and selection controls

#### FadingTextField
Themed text input with support for common form workflows.
Forms the base for user data entry across demos and tests.

#### FadingCheckbox
Boolean selection control for forms and settings.
Designed to match package-level spacing and color tokens.

#### FadingSwitch
Immediate on/off toggle control.
Useful for settings rows and preference screens.

#### FadingRadioGroup
Single-selection group for mutually exclusive options.
Pairs well with compact settings and checkout-style flows.

#### FadingSelect
Custom select/dropdown built with OverlayEntry.
Ensures form controls remain visually consistent across platforms.

#### FadingSlider
Continuous value input for ranges such as volume, opacity, or thresholds.
Uses package theme tokens for track, thumb, and active states.

#### FadingChips
Selectable and filter chips for tags and quick multi-select.
Supports compact interaction patterns for dense UIs.

### Navigation and structure

#### FadingTabBar
Tabbed navigation component for section switching.
Strong fit for compact screen-level navigation.

#### FadingAccordion
Expandable/collapsible sections with animated transitions.
Optimized for settings pages and FAQ-like content blocks.

#### FadingPagination
Page navigation control for lists and table-like data views.
Adds clear movement across large datasets.

### Feedback and overlay patterns

#### FadingModal
Reusable dialog shell with backdrop, body, and actions.
Provides a consistent replacement for platform-default dialogs.

#### FadingSnackbar
Bottom notification with optional action.
Supports persistent-action feedback patterns.

#### FadingToast
Lightweight transient notification for brief status updates.
Complements snackbar usage for less intrusive feedback.

#### FadingTooltip
Context hint shown on hover, focus, or long press.
Improves discoverability for icon-only or compact controls.

#### FadingBadge
Compact status badge for short labels and semantic states.
Supports neutral, success, warning, and critical tone variants.

### Progress, date, time, and data

#### FadingProgressIndicator
Themed loading/progress indicator family.
Used for async task feedback and long-running operations.

#### FadingDatePicker
Custom calendar picker with month navigation.
Delivers a consistent date input experience inside the package style.

#### FadingTimePicker
Themed time selection control with package-consistent look and feel.
Complements date picking for scheduling workflows.

#### FadingDataTable
Styled data table with sortable headers and row states.
Provides dashboard-grade tabular presentation in the same design system.

## Next highest priority (fast impact)

1. FadingStepper
2. FadingSegmentedControl
3. FadingBottomSheet
4. FadingMenu

## Navigation and action widgets (next wave)

### FadingBottomSheet
Partial-height bottom panel for action lists, short forms, and detail previews.

### FadingDrawer
Side panel for navigation and persistent app actions.

### FadingMenu
Anchored menu/popover for contextual actions from icon buttons and row menus.

### FadingBreadcrumbs
Lightweight path navigation for dashboard/admin page hierarchies.

## Form and input expansion

### FadingAutocomplete
Type-ahead text field with keyboard navigation and async options support.

### FadingMultiSelect
Multi-value selection control (dropdown/chips hybrid).

### FadingRangeSlider
Dual-thumb slider for selecting min and max values.

### FadingFieldGroup
Reusable wrapper for label, helper text, error text, and validation state.

### FadingOTPField
Focused multi-cell code input for authentication flows.

## Data and Feedback States

### FadingSkeleton
Placeholder loading blocks to improve perceived performance.

### FadingEmptyState
Reusable empty/no-results state with icon, message, and actions.

### FadingTimeline
Chronological event feed for activity and history views.

### FadingStatCard
Compact KPI card with optional trend indicator and sparkline area.

### FadingInlineBanner
In-content informational/warning/success banner with optional actions.

## Layout primitives

### FadingAppBar
Consistent app-level top bar with title, actions, and optional tabs.

### FadingPageScaffold
Opinionated shell for page title, body, footer actions, and optional side panel.

### FadingSplitPane
Resizable dual-pane layout for desktop/tablet workflows.

### FadingResponsiveGrid
Token-driven responsive grid with breakpoint rules.

### FadingSection
Section-level wrapper with heading, description, and action slot.