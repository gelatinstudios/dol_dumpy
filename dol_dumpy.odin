
package dol_dumpy

import "core:os"
import "core:fmt"
import "core:flags"

DOL_Header :: struct #packed {
    text_offsets:            [7]u32be,
    data_offsets:           [11]u32be,
    text_loading_addresses:  [7]u32be,
    data_loading_addresses: [11]u32be,
    text_section_sizes:      [7]u32be,
    data_section_sizes:     [11]u32be,
    bss_address:                u32be,
    bss_size:                   u32be,
    entry_point:                u32be,
}

Type :: enum {
    string, float,
}

Options :: struct {
    dol:     os.Handle `args:"pos=0,required,file=r" usage:"main.dol"`,
    type:    Type      `args:"pos=1,required"        usage:"data type (valid: string, float)"`,
    base:    u32be     `args:"pos=2,required"        usage:"virtual address"`,
    offset:  int       `args:"pos=3"                 usage:"optional offset from base address"`  
}

main :: proc() {
    options: Options
    flags.parse_or_exit(&options, os.args)

    target_address := options.base + u32be(options.offset)
    
    dol, _ := os.read_entire_file(options.dol)

    assert(len(dol) > size_of(DOL_Header))
    
    header := cast(^DOL_Header)&dol[0]

    for data_offset, i in header.data_offsets {
        loading_address := header.data_loading_addresses[i]
        size := header.data_section_sizes[i]
        end := loading_address + size
        if target_address >= loading_address &&
           target_address < end
        {
            offset := data_offset + (target_address - loading_address)

            switch options.type {
                case .string:
                    str := cast(cstring)&dol[offset]
                    fmt.println(str)

                case .float:
                    x := cast(^f32be)&dol[offset]
                    fmt.println(x^)
            }

            break
        }
    }
}
