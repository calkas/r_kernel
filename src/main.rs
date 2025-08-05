#![no_std]
#![no_main]
mod vga_printer;
use core::{arch::asm, panic::PanicInfo};
use vga_printer::Printer;
use x86_64::registers::control::{Cr0, Cr0Flags};

#[no_mangle]
#[inline(never)]
pub extern "C" fn _start() -> ! {
    let mut printer = Printer::default();
    printer.set_foreground(vga_printer::Color::LightGreen);
    printer.set_position(10, 0);
    printer.print("R_OS\n");

    if Cr0::read().contains(Cr0Flags::PROTECTED_MODE_ENABLE) {
        printer.print("Cr0 set\n");
    }

    if Cr0::read().contains(Cr0Flags::PAGING) {
        printer.print("PG set\n");
    }
    unsafe {
        asm!("nop");
    }

    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
