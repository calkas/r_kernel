#![no_std]
#![no_main]

//#[macro_use]

mod vga_printer;
use core::panic::PanicInfo;
use x86_64::registers::control::{Cr0, Cr0Flags};

#[no_mangle]
#[inline(never)]
pub extern "C" fn _start() -> ! {
    welcome();
    if Cr0::read().contains(Cr0Flags::PROTECTED_MODE_ENABLE)
        && Cr0::read().contains(Cr0Flags::PAGING)
    {
        kernel_logln!("Cr0 flags: PAGING, PROTECTED_MODE_ENABLE set");
    }
    loop {}
}

fn welcome() {
    vga_printer::PRINTER
        .lock()
        .set_foreground(vga_printer::Color::Green);

    kernel_logln!("..::Welcome to R_OS::..");

    vga_printer::PRINTER
        .lock()
        .set_foreground(vga_printer::Color::White);
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    kernel_panic_log!("Panicked: {}", info.message());
    loop {}
}
