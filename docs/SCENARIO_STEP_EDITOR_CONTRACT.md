# Scenario Step Editor Contract

## Purpose

This document defines the editable scenario-step model required for the Stage 10.2 follow-up brief.

## Current Problem

- Flutter currently stores only scenario metadata (`ScenarioItem`)
- Native Android storage keeps executable recorded actions in `ScenarioActionStore`
- There is no typed Flutter-side editable step model yet

## Step Model

Each editable scenario step is represented by:

- `type`
- `pointerCount`
- `startX`
- `startY`
- `endX`
- `endY`
- `durationMs`
- `stepDelayMs`

## Semantics

- `durationMs` is the gesture duration of the action itself
- `stepDelayMs` is the delay after this step before the next step begins
- default `stepDelayMs` is `1000`
- `stepDelayMs` must be stored per step so edited scenarios can preserve timing

## Ownership

- Flutter owns the typed editor model (`ScenarioStep`)
- Android native layer remains the source of executable action storage
- Flutter accesses native step payload only through typed `PlatformBridgeRepository` methods

## Compatibility Rules

- Existing stored/imported actions without `stepDelayMs` must load with fallback `1000`
- Existing execution must keep working for old scenarios
- Import/export JSON must preserve `stepDelayMs` once present

## Phase 1 Outcome

Phase 1 is considered complete when:

- Flutter has a typed `ScenarioStep` domain model
- bridge methods can read scenario steps from native storage
- bridge methods can write scenario steps back to native storage
- storage contract is documented here before the full editor UI is built
