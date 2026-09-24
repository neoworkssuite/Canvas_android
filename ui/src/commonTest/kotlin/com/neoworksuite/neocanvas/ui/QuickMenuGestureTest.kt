package com.neoworksuite.neocanvas.ui

import androidx.compose.ui.input.pointer.PointerType
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class QuickMenuGestureTest {
    @Test
    fun eraser_ended_stylus_is_not_treated_as_touch_input() {
        assertTrue(isStylusInput(PointerType.Stylus))
        assertTrue(isStylusInput(PointerType.Eraser))
        assertFalse(isStylusInput(PointerType.Touch))
    }

    @Test
    fun quick_menu_hold_is_reserved_for_non_painting_finger_on_pencil_tools() {
        assertTrue(shouldArmQuickMenu(
            isStylus = false,
            fingerPaintingEnabled = false,
            tool = Tool.Brush,
            objectArrangePicking = false,
        ))
        assertTrue(shouldArmQuickMenu(false, false, Tool.Eraser, false))
        assertTrue(shouldArmQuickMenu(false, false, Tool.Smudge, false))
        assertTrue(shouldArmQuickMenu(false, false, Tool.Liquify, false))

        assertFalse(shouldArmQuickMenu(true, false, Tool.Brush, false))
        assertFalse(shouldArmQuickMenu(false, true, Tool.Brush, false))
        assertFalse(shouldArmQuickMenu(false, false, Tool.Pan, false))
        assertFalse(shouldArmQuickMenu(false, false, Tool.Brush, true))
    }
}
