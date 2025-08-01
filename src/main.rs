#![no_std]
#![no_main]
mod vga_printer;
use core::panic::PanicInfo;
use vga_printer::Printer;

#[no_mangle]
pub extern "C" fn _start() -> ! {
    entry_32_bit();
}

#[no_mangle]
#[inline(never)]
fn entry_32_bit() -> ! {
    let mut printer = Printer::default();
    printer.print_character(b'R');
    loop {}
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
