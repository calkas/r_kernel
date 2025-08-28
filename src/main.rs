#![no_std]
#![no_main]
use core::panic::PanicInfo;
use r_kernel::components::{info, vga_printer};
use r_kernel::{kernel_logln, kernel_panic_log};

#[unsafe(no_mangle)]
#[inline(never)]
pub extern "C" fn _start() -> ! {
    info::print_welcome_message();
    r_kernel::init();

    // Breakpoint test
    x86_64::instructions::interrupts::int3();

    kernel_logln!("Still Running...");
    loop {}
}

#[panic_handler]
fn panic(info: &PanicInfo) -> ! {
    kernel_panic_log!("{}", info.message());
    loop {}
}
