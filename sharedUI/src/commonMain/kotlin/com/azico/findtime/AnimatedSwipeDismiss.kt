package com.azico.findtime

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.SwipeToDismissBox
import androidx.compose.material3.SwipeToDismissBoxValue
import androidx.compose.material3.rememberSwipeToDismissBoxState
import androidx.compose.runtime.Composable

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun <T : Any> AnimatedSwipeDismiss(
    item: T,
    background: @Composable (isDismissed: Boolean) -> Unit,
    content: @Composable () -> Unit,
    onDismiss: (T) -> Unit
) {
    val dismissState = rememberSwipeToDismissBoxState(
        confirmValueChange = { value ->
            if (value == SwipeToDismissBoxValue.EndToStart) {
                onDismiss(item)
                true
            } else {
                false
            }
        }
    )

    AnimatedVisibility(
        visible = dismissState.currentValue != SwipeToDismissBoxValue.EndToStart,
        exit = shrinkVertically() + fadeOut()
    ) {
        SwipeToDismissBox(
            state = dismissState,
            backgroundContent = {
                background(dismissState.targetValue == SwipeToDismissBoxValue.EndToStart)
            }
        ) {
            content()
        }
    }
}
