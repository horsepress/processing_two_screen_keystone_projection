# processing_two_screen_keystone_projection
Processing (Java - see https://processing.org/) code originally used for projecting video onto a climbing wall.

This was used to allow the output of two projectors to be aligned with angled artificial climbing walls, such that a projected video of a climber can be aligned with the holds on the wall.

![Example](/example.png)

It uses the keystone library to do this.

A basic keyboard interface is used to control the location of the videos:

* l - load a saved layout
* s - save a layout (these get saved to a json file)
* r - go back to start of video
* f - skip forwards
* b - skip backwards
* F - skip lots forwards
* B - skip lots back
* [space] - pause video
* q - double speed
* n - normal speed
* a - normal speed
* z - half speed
* [ - skip back one video
* ] - skip forwards one video
* t - toggle text display
* m - mute video

* c - enter / leave calibration mode
* / - adjust left-hand video
* * - adjust right-hand video
* - - move edges by 1 pixel
* + - move edges by 10 pixels
* 1 - select bottom left corner for adjustment
* 3 - select bottom right corner for adjustment
* 7 - select top left corner for adjustment
* 9 - select top right corner for adjustment
* # - toggle moving or cropping of edges
* 2 / 4 / 6 / 8 - move / crop corner


