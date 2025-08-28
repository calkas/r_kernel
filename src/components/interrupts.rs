use super::vga_printer;
use crate::kernel_exception_log;
use lazy_static::lazy_static;
use x86_64::structures::idt::{InterruptDescriptorTable, InterruptStackFrame};

lazy_static! {
    static ref IDT: InterruptDescriptorTable = {
        let mut idt = InterruptDescriptorTable::new();
        idt.divide_error.set_handler_fn(div_by_zero_handler);
        idt.breakpoint.set_handler_fn(breakpoint_handler);
        idt.double_fault.set_handler_fn(double_fault_handler);
        idt
    };
}

pub fn idt_init() {
    IDT.load();
}

extern "x86-interrupt" fn breakpoint_handler(_stack_frame: InterruptStackFrame) {
    kernel_exception_log!("Breakpoint");
}

extern "x86-interrupt" fn div_by_zero_handler(_stack_frame: InterruptStackFrame) {
    kernel_exception_log!("Div by zero");
}

extern "x86-interrupt" fn double_fault_handler(
    stack_frame: InterruptStackFrame,
    _error_code: u64,
) -> ! {
    panic!("Double fault!: {:#?}", stack_frame);
}
