#![warn(unused_imports)]
#![allow(dead_code)]
use core::ptr::write_volatile;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
#[repr(u8)]
pub enum Color {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGray = 7,
    DarkGray = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    Pink = 13,
    Yellow = 14,
    White = 15,
}

#[derive(Default)]
struct ScreenCoords {
    row: u8,
    col: u8,
}

struct TextBufferAttribute {
    foreground_color: u8,
    background_color: u8,
    blink: bool,
}
impl Default for TextBufferAttribute {
    fn default() -> Self {
        Self {
            foreground_color: Color::White as u8,
            background_color: Color::Black as u8,
            blink: false,
        }
    }
}

impl TextBufferAttribute {
    fn get_attribute(&self) -> u8 {
        let mut attribute: u8 = 0;
        attribute |= ((self.background_color & 0x07) << 4) | (self.foreground_color & 0x0F);

        if self.blink {
            attribute |= 0b1000_0000;
        }
        attribute
    }
}

/// This is a raw pointer to the VGA text buffer at address 0xb8000.
/// Dereferencing this pointer is unsafe and must only be done in appropriate contexts,
/// such as when running in an environment where direct access to VGA memory is allowed.
/// 80 x 25 = 2000 chars × 2 bytes = 4000 bytes
const VGA_BUFFER: *mut u8 = 0xb8000 as *mut u8;
const SCREEN_WIDTH: usize = 80;
const SCREEN_HEIGHT: usize = 25;

/// # Printer
/// vga text mode
#[derive(Default)]
pub struct Printer {
    text_attribute: TextBufferAttribute,
    cursor_position: ScreenCoords,
}

impl Printer {
    pub fn print(&mut self, text: &str) {
        for character in text.bytes() {
            self.print_character(character);
        }
    }

    pub fn set_foreground(&mut self, color: Color) {
        self.text_attribute.foreground_color = color as u8;
    }

    pub fn set_background(&mut self, color: Color) {
        self.text_attribute.background_color = color as u8;
    }

    pub fn enable_blink(&mut self) {
        self.text_attribute.blink = true;
    }

    pub fn disable_blink(&mut self) {
        self.text_attribute.blink = false;
    }

    pub fn set_position(&mut self, row: u8, col: u8) {
        if row < SCREEN_HEIGHT as u8 && col < SCREEN_WIDTH as u8 {
            self.cursor_position = ScreenCoords { row, col };
        }
    }

    pub fn print_character(&mut self, character: u8) {
        match character {
            b'\n' => self.new_line(),
            _ => {
                if self.cursor_position.col >= SCREEN_WIDTH as u8 {
                    self.new_line();
                }

                let offset = (self.cursor_position.row as usize * SCREEN_WIDTH
                    + self.cursor_position.col as usize)
                    * 2;
                unsafe {
                    write_volatile(VGA_BUFFER.add(offset), character);
                    write_volatile(
                        VGA_BUFFER.add(offset + 1),
                        self.text_attribute.get_attribute(),
                    );
                }
                self.cursor_position.col += 1;
            }
        }
    }

    fn new_line(&mut self) {
        self.cursor_position.col = 0;
        self.cursor_position.row += 1;
        if self.cursor_position.row > SCREEN_HEIGHT as u8 {
            self.cursor_position.row = 0;
        }
    }
}
