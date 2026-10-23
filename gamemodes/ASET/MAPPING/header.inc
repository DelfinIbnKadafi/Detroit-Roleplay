
// atasi warning 213
stock MapText(objectid, const text[], materialindex, materialsize, const fontface[], fontsize, bold, fontcolour, backcolour, textalignment)
{
    return SetObjectMaterialText(
        objectid,
        text,
        materialindex,
        t_OBJECT_MATERIAL_SIZE:materialsize,
        fontface,
        fontsize,
        bool:bold,
        fontcolour,
        backcolour,
        t_OBJECT_MATERIAL_TEXT_ALIGN:textalignment
    );
}
#define SetObjectMaterialText MapText




#include "ASET/MAPPING/City_Hall.pwn"

#include "ASET/MAPPING/Main.pwn"