# Sensorial

<a href="https://pub.dev/packages/sensorial"><img src="https://img.shields.io/pub/v/sensorial" alt="Pub version" /></a> <a href="https://pub.dev/packages/sensorial/score"><img src="https://badges.bar/sensorial/pub%20points" alt="Pub points" /></a>

Provides sensor manipulation utilities for Flutter.

## Usage

This library exports a global variable named `sensorial`, which you can use to access the API.

### Interactive mode

The interactive mode allows the user to access the real-time sensor API from the device, using 
`sensorial.interactive()`. This returns a builder object that you can use to configure the **data
collection**:

- `interval(Duration)`: defines how often the events are sent (e.g. every 15 ms). If this method
  is called more than once, only the last call will be considered, so
  
  ```dart
  sensorial.interactive()
      .interval(Duration(milliseconds: 5))
      .interval(Duration(milliseconds: 10))
  ```

will set the duration to 10 ms. If not called, this defaults to 30 ms.

- `source(Point3<X, Y> Function(int))`: defines an alternative source to provide the events. The 
  argument to this callback is an integer that starts with 0 and is incremented for every event.
  Each event will be triggered based on the interval provided by the `interval` method. For example,
  if random values should be used instead of real accelerometer values from the device, you can do
  
  ```dart
  final Random random = Random();
  sensorial.interactive()
      .interval(Duration(milliseconds: 30))
      .source((i) {
          return Point3(
            // Use the same value defined in `interval`
            // to obtain consistent events
            Duration(milliseconds: i * 30),
            // Generate a double that goes from -10 to 10
            x: random.nextDouble() * 20 - 10,
            y: random.nextDouble() * 20 - 10,
            z: random.nextDouble() * 20 - 10,
          );
      })
  ```
  
  If this method is called more than once, only the last call will be considered. If not called, this
  defaults to using the device's sensor API to provide the sensor events.

- `sensor(Sensor)`: defines the inertial sensor to be used ([accelerometer](https://pub.dev/documentation/sensorial/latest/sensorial/Accelerometer-class.html)
  or [gyroscope](https://pub.dev/documentation/sensorial/latest/sensorial/Gyroscope-class.html), not
  both). After calling this method, another set of methods will be available, this time to configure
  the **data processing**:
  
  - `operation(DataTransformation)`: defines which transformation to apply for each sensor point. If
    [DataTransformation.none()](https://pub.dev/documentation/sensorial/latest/sensorial/DataTransformation/none.html),
    no transformation will be applied and the points will be yielded as they are. If [DataTransformation.variation()](https://pub.dev/documentation/sensorial/latest/sensorial/DataTransformation/variation.html),
    each yielded point will be the difference between two consecutive original points. 
  
  - `metric(Metric<S>)`: defines the unit to be used for each yielded point. If you defined the sensor
    to be accelerometer, you can only use the accelerometer metrics in this method, namely [acceleration](https://pub.dev/documentation/sensorial/latest/sensorial/Acceleration-class.html)
    (m/s²) and [accelerometer's angle](https://pub.dev/documentation/sensorial/latest/sensorial/AccelerometerAngle-class.html) (º).
    If you defined the sensor to be gyroscope, you can use the only gyroscope metric available, [angular
    velocity](https://pub.dev/documentation/sensorial/latest/sensorial/AngularVelocity-class.html) (rad/s).
    If this method is called more than once, all the calls will be considered: this allows you to yield the 
    values of more than one metric. If not called, this will yield no points. Each transformation can be
    consulted in this table:
    
    |      **Metric**     |   **Sensor**  | **Original value** | **Transformed value** | **Transformed unit** |
    |:-------------------:|:-------------:|:------------------:|:---------------------:|:--------------------:|
    |     Acceleration    | Accelerometer |      x (m/s²)      |           x           |         m/s²         |
    | Accelerometer angle | Accelerometer |      x (m/s²)      |  9.18368 * (9.8 - x)  |      º (degrees)     |
    |   Angular velocity  |   Gyroscope   |      x (rad/s)     |           x           |         rad/s        |
    
   - `build()`: creates an [asynchronous sensor data](https://pub.dev/documentation/sensorial/latest/sensorial/AsyncSensorData-class.html),
      which you can obtain its corresponding stream by calling its `collect().value` attribute.
      
#### Complete example

```dart
final AsyncSensorData<Accelerometer, Duration, double> data;
data = sensorial.interactive()
    .interval(const Duration(milliseconds: 20))
    .sensor(Sensor.accelerometer)
    .operation(DataTransformation.none())
    .metric(Metric.acceleration)
    .metric(Metric.accelerometerAngle)
    .build()
    
final Stream<SensorValue<Accelerometer, Duration, double>> stream;
stream = data.collect().value;
```

#### Sensor value and its transposed version

To understand the values yielded by the above stream, let's suppose a point received by the 
accelerometer contains the following data:

- Duration: 80 ms
- x-axis acceleration: 2 m/s²
- y-axis acceleration: 5 m/s²
- z-axis acceleration: 3 m/s²
- x-axis accelerometer angle: 10°
- x-axis accelerometer angle: 20°
- x-axis accelerometer angle: 40°

The following holds true:

```dart
final Stream<SensorValue<Accelerometer, Duration, double>> stream;
stream = data.collect().value;

final SensorValue<Accelerometer, Duration, double> v0 = await stream.first;
print(v0.key);                                  // Duration(milliseconds: 80))
print(v0.metrics);                              // {Metric.acceleration, Metric.accelerometerAngle}

final Point3<Duration, Map<Metric<Accelerometer>, double>> p0 = v0.values;
print(p0.key);                                  // Duration(milliseconds: 80))
print(p0.x);                                    // {Metric.acceleration: 2, Metric.accelerometerAngle: 10}
print(p0.y);                                    // {Metric.acceleration: 5, Metric.accelerometerAngle: 20}
print(p0.z);                                    // {Metric.acceleration: 3, Metric.accelerometerAngle: 40}
```

The following also holds true:

```dart
final Stream<SensorValue<Accelerometer, Duration, double>> stream;
stream = data.collect().value;

final SensorValue<Accelerometer, Duration, double> v0 = await stream.first;
final TransposedSensorValue<Accelerometer, Duration, double> tv0 = v0.transpose();
print(tv0.key);                                 // Duration(milliseconds: 80))
print(tv0.metrics);                             // {Metric.acceleration, Metric.accelerometerAngle}

final Map<Metric<Accelerometer>, Point3<Duration, double>> p0 = tv0.points;
print(p0.keys);                                 // {Metric.acceleration, Metric.accelerometerAngle}
print(p0[Metric.accelerometer]!.key);           // Duration(milliseconds: 80))
print(p0[Metric.accelerometer]!.x);             // 2
print(p0[Metric.accelerometer]!.y);             // 5
print(p0[Metric.accelerometer]!.z);             // 3
print(p0[Metric.accelerometerAngle]!.key);      // Duration(milliseconds: 80))
print(p0[Metric.accelerometerAngle]!.x);        // 10
print(p0[Metric.accelerometerAngle]!.y);        // 20
print(p0[Metric.accelerometerAngle]!.z);        // 40
```

_Tip_: if you want to access each metric's value simultaneously (e.g. plotting in a graph),
use the default sensor value. If you want to access each metric's value individually (e.g.
parsing from a file row by row), use the transposed sensor value.

#### Metric filtering

If you have a sensor data of any kind, you can easily filter by a given metric by using the
`metric(Metric<S>)` method. Using the previous example:

```dart
final AsyncSensorData<Accelerometer, Duration, double> data;
data = sensorial.interactive()
    .interval(const Duration(milliseconds: 20))
    .sensor(Sensor.accelerometer)
    .operation(DataTransformation.none())
    .metric(Metric.acceleration)
    .metric(Metric.accelerometerAngle)
    .build()
    
final AsyncTransposedSensorData<Accelerometer, Duration, double> transposed;
transposed = data.transpose();

final AsyncMetricData<Duration, double> metricData = transposed.metric(Metric.acceleration);
print(await metricData.x.first);                // Point2(x: Duration(milliseconds: 80), y: 2)
print(await metricData.y.first);                // Point2(x: Duration(milliseconds: 80), y: 5)
print(await metricData.z.first);                // Point2(x: Duration(milliseconds: 80), y: 3)
```
