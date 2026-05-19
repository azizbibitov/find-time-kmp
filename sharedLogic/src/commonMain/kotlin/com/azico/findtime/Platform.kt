package com.azico.findtime

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform