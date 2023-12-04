/*
 *     Discipulus
 *     Copyright (C) 2023  Sam Wagenaar
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::io::Read;
use std::process::{Command, Stdio};
use std::fs::canonicalize;

#[no_mangle]
pub unsafe extern "C" fn ffi_add(a: u32, b: u32) -> u32 {
    return a + b;
}

fn test(fname: &str) {
    println!("{}", fname);
}

/// Example usage: words("/home/sam/bin/whitakers-words/", "/home/sam/bin/whitakers-words/bin/words", "raeda");
fn words(working_dir: &str, exec: &str, word: &str) -> String {
    let mut child = Command::new(canonicalize(exec).expect("Failed to canonicalize exec path"))
        .stdin(Stdio::piped())
        .arg(word)
        .current_dir(working_dir)
        .stdout(Stdio::piped())
        .spawn()
        .expect("Failed to run words");
    let mut buf: String = "".to_string();
    child.stdout.take().unwrap().read_to_string(&mut buf).expect("Failed to receive words output");
    return buf;
}

fn c_to_str(ptr: *const c_char) -> String {
    let cstr = unsafe { CStr::from_ptr(ptr) };
    let rstr: &str = cstr.to_str().expect("Failed to decode string");
    return rstr.to_owned();
}

#[no_mangle]
pub unsafe extern "C" fn ffi_test(ptr: *const c_char) -> *mut c_char {
    let cstr = unsafe { CStr::from_ptr(ptr) };
    let rstr: &str = cstr.to_str().expect("Failed to decode string");
    test(rstr);
    let out: String = "test [".to_owned() + rstr + "] other_test";
    let cout = CString::new(out).expect("Failed to convert output to cstring");
    return cout.into_raw();
}

#[no_mangle]
pub unsafe extern "C" fn ffi_words(working_dir: *const c_char, exec: *const c_char, word: *const c_char) -> *mut c_char {
    let out: String = words(&c_to_str(working_dir), &c_to_str(exec), &c_to_str(word));
    return CString::new(out).expect("Failed to convert output to cstring").into_raw();
}

#[no_mangle]
pub unsafe extern "C" fn ffi_drop_string(ptr: *mut c_char) {
    if ptr.is_null() {
        return;
    }
    drop(CString::from_raw(ptr));
}
