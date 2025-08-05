#![no_std]
#![no_main]
mod vga_printer;
use core::fmt::Write;
use core::{arch::asm, panic::PanicInfo};
use vga_printer::Printer;
use x86_64::registers::control::{Cr0, Cr0Flags};

#[no_mangle]
#[inline(never)]
pub extern "C" fn _start() -> ! {
    let mut printer = Printer::default();
    printer.set_foreground(vga_printer::Color::LightGreen);
    writeln!(printer, "..::Welcome to R_OS::..").unwrap();

    if Cr0::read().contains(Cr0Flags::PROTECTED_MODE_ENABLE)
        && Cr0::read().contains(Cr0Flags::PAGING)
    {
        writeln!(printer, "Cr0 flags: PAGING and PROTECTED_MODE_ENABLE set").unwrap();
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
