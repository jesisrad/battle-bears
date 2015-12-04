#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_LSM303.h>

Adafruit_LSM303 lsm;

void setup() {
  Serial.begin(9600);

  // Try to initialise and warn if we couldn't detect the chip
  if (!lsm.begin())
  {
    Serial.println("Oops ... unable to initialize the LSM303. Check your wiring!");
    while (1);
  }
}

void loop() {
  sensors_vec_t   orientation;
  lsm.read();
  
  // Use the simple AHRS function to get the current orientation.
  if (getOrientation(&orientation))
  {
    Serial.print(orientation.roll);
    Serial.print(F(":"));
    Serial.print(orientation.pitch);
    Serial.print(F(":"));
    Serial.print(orientation.heading);
    Serial.println(F(""));
  }
  
  delay(100);
}

/* 
 * Compute orientation based on accelerometer and magnetometer data. 
 */
bool getOrientation(sensors_vec_t* orientation) {

  float const PI_F = 3.14159265F;

  // roll: Rotation around the X-axis. -180 <= roll <= 180                                          
  // a positive roll angle is defined to be a clockwise rotation about the positive X-axis          
  //                                                                                                
  //                    y                                                                           
  //      roll = atan2(---)                                                                         
  //                    z                                                                           
  //                                                                                                
  // where:  y, z are returned value from accelerometer sensor                                      
  orientation->roll = (float)atan2(lsm.accelData.y, lsm.accelData.z);

  // pitch: Rotation around the Y-axis. -180 <= roll <= 180                                         
  // a positive pitch angle is defined to be a clockwise rotation about the positive Y-axis         
  //                                                                                                
  //                                 -x                                                             
  //      pitch = atan(-------------------------------)                                             
  //                    y * sin(roll) + z * cos(roll)                                               
  //                                                                                                
  // where:  x, y, z are returned value from accelerometer sensor                                   
  if (lsm.accelData.y * sin(orientation->roll) + lsm.accelData.z * cos(orientation->roll) == 0)
    orientation->pitch = lsm.accelData.x > 0 ? (PI_F / 2) : (-PI_F / 2);
  else
    orientation->pitch = (float)atan(-lsm.accelData.x / (lsm.accelData.y * sin(orientation->roll) + \
                                                                     lsm.accelData.z * cos(orientation->roll)));

  // heading: Rotation around the Z-axis. -180 <= roll <= 180                                       
  // a positive heading angle is defined to be a clockwise rotation about the positive Z-axis       
  //                                                                                                
  //                                       z * sin(roll) - y * cos(roll)                            
  //   heading = atan2(--------------------------------------------------------------------------)  
  //                    x * cos(pitch) + y * sin(pitch) * sin(roll) + z * sin(pitch) * cos(roll))   
  //                                                                                                
  // where:  x, y, z are returned value from magnetometer sensor                                    
  orientation->heading = (float)atan2(lsm.magData.z * sin(orientation->roll) - lsm.magData.y * cos(orientation->roll), \
                                      lsm.magData.x * cos(orientation->pitch) + \
                                      lsm.magData.y * sin(orientation->pitch) * sin(orientation->roll) + \
                                      lsm.magData.z * sin(orientation->pitch) * cos(orientation->roll));

  // Convert angular data to degree 
  orientation->roll = orientation->roll * 180 / PI_F;
  orientation->pitch = orientation->pitch * 180 / PI_F;
  orientation->heading = orientation->heading * 180 / PI_F;

  return true;
}


