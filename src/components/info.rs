use super::vga_printer;
use crate::kernel_logln;
use x86_64::instructions::tables::DescriptorTablePointer;
use x86_64::registers::control::{Cr0, Cr0Flags};
use x86_64::registers::segmentation::{Segment, CS};

/// GDT - In Protected Mode Kernel sets all segments base to 0x00000000 (Data and code segment)
/// and limit to 0xFFFFF (4GB) Thus logical address (segment:offset) is equal to linear address
/// We don't care about segmentation. All addresses are flat
/// In flat model
/// Segment base: 0x00000000.
/// Offset = real address.
/// Linear address = offset.
/// int a = 67;
/// &a -> 0x12345
/// DS => 0x00000000, &a => 0x12345 => Address =0x00012345
///
/// In 64-bit mode, segmentation is mostly disabled: all segment bases are treated as zero,
/// and limits are ignored, creating a flat address space
pub fn kernel_info() {
    kernel_logln!("KERNEL INFO:");

    // GTD output is only for fun because in 64 - bit we have a flat address space
    gdt_info();

    if Cr0::read().contains(Cr0Flags::PROTECTED_MODE_ENABLE)
        && Cr0::read().contains(Cr0Flags::PAGING)
    {
        kernel_logln!("Cr0 flags: PAGING, PROTECTED_MODE_ENABLE set");
    }
}

fn gdt_info() {
    let gdtr: DescriptorTablePointer = x86_64::instructions::tables::sgdt();

    kernel_logln!("GDT descriptors count {}", (gdtr.limit + 1) / 8);

    let gdt: *const u64 = gdtr.base.as_ptr::<u64>();
    unsafe {
        let entry0 = gdt;
        kernel_logln!("Null descriptor: {:#x}", *entry0);

        let entry1 = entry0.add(1);
        kernel_logln!("Code segment: {:#x}", *entry1);

        let entry2 = entry0.add(2);
        kernel_logln!("Data segment: {:#x}", *entry2);
    }

    let cs = CS::get_reg();
    if cs.0 == 0x8 {
        // Code segment
        kernel_logln!("CS is using second entry of GDT (Code segment)");
    }
}

pub fn print_welcome_message() {
    vga_printer::PRINTER
        .lock()
        .set_foreground(vga_printer::Color::Green);

    kernel_logln!("..::Welcome to R_OS::..");

    vga_printer::PRINTER
        .lock()
        .set_foreground(vga_printer::Color::White);
}
