# Wizard Data Loading Fix

## Problem
The store creation wizard (`OnboardingWizardPage`) was not displaying existing payment methods and opening hours from the database.

## Root Cause
The wizard relied on data from `StoresManagerCubit.state.activeStore.relations`, which might not contain complete relational data (hours, payment methods, etc.) when the wizard first loads.

## Solution
Added explicit data fetching when the wizard opens to ensure all store relations are loaded before displaying the wizard pages.

### Implementation Details

#### 1. Data Fetch on Init (`settings_wizard_page.dart`)
```dart
@override
void initState() {
  super.initState();
  _loadStoreData(); // Fetch complete store data
}

Future<void> _loadStoreData() async {
  final storeRepository = getIt<StoreRepository>();
  final cubit = context.read<StoresManagerCubit>();
  
  final result = await storeRepository.fetchStore(widget.storeId);
  
  result.fold(
    (error) => setState(() => _isLoadingStoreData = false),
    (store) {
      cubit.updateStoreInState(widget.storeId, store);
      setState(() => _isLoadingStoreData = false);
    },
  );
}
```

#### 2. State Update Method (`store_manager_cubit.dart`)
```dart
void updateStoreInState(int storeId, Store updatedStore) {
  final currentState = state;
  if (currentState is StoresManagerLoaded) {
    final storeWithRole = currentState.stores[storeId];
    if (storeWithRole != null) {
      final updatedStoreWithRole = storeWithRole.copyWith(store: updatedStore);
      final updatedStores = Map<int, StoreWithRole>.from(currentState.stores);
      updatedStores[storeId] = updatedStoreWithRole;
      emit(currentState.copyWith(stores: updatedStores));
    }
  }
}
```

## Backend Requirements
The endpoint `/admin/stores/:id` must return complete store data including all relations:
- `hours` - Array of store opening hours
- `payment_method_groups` - Array of payment method groups with methods

## Testing
1. Create a store with hours and payment methods
2. Navigate to `/stores/:id/wizard-settings`
3. Verify hours appear in step 2
4. Verify payment methods appear in step 3

## Future Improvements
- Consider caching mechanism to avoid unnecessary API calls
- Add retry logic for failed data fetches
- Add telemetry to track when data is missing from initial load
