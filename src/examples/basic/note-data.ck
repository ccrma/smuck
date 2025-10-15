@import "../../smuck.ck"
//-----------------------------------------------------------------------------
// name: note-data.ck
// desc: This example shows how to set/get the 'data' and 'text' fields of ezNote objects
//
// author: Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------

// DATA
// ------------------------------------------------------------
// The 'data' variable is a float array that can be set and retrieved from ezNote objects
// It can be used to store any kind of arbitrary data, could be useful for
// expression/CC-like information

// Create a note
ezNote note;

chout <= "Created note with default parameters:" <= IO.newline();
note.print(); 

// Set some custom data in 'data' array
note.data(0, 42.0);
chout <= "Set user data field at index 0 to 42.0:" <= IO.newline();
note.print();

// Set custom data beyond current array size
note.data(5, 99.0);
chout <= "Set user data field at index 5 to 99.0:" <= IO.newline();
note.print();

// Get note data at index 0
note.data(0) => float data;
chout <= "Get user data field at index 0:" <= IO.newline();
chout <= data <= IO.newline();

// Set custom data with array
note.data([1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]);
chout <= "Set user data field with array:" <= IO.newline();
note.print();

// Negative index works
note.data(-1) => data;
chout <= "Get user data field at index -1:" <= IO.newline();
chout <= data <= IO.newline();

// TEXT
// ------------------------------------------------------------
// The 'text' variable is a string annotation that can be set 
// and retrieved from ezNote objects

ezNote note2;
note2.text("This is a test");
chout <= "Set text field to 'This is a test':" <= IO.newline();
note2.print();

// Get text field
note2.text() => string text;
chout <= "Get text field:" <= IO.newline();
chout <= text <= IO.newline();