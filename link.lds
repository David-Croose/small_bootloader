OUTPUT_ARCH(arm)
ENTRY(_start)

SECTIONS
{ 
	.text 0x00000000 :
  	{
  		*(.boot)
  		*(.text*)
  		__image_end = .;
  	}
}

ASSERT(__image_end <= 4096, "image can not larger than 4096B");