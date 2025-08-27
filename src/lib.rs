#![no_std]
#![feature(abi_x86_interrupt)]
pub mod components;

use crate::components::interrupts::idt_init;

/// # components initialization
pub fn init() {
    idt_init();
}
