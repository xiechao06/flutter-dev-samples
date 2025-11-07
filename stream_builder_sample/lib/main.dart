import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const StreamBuilderExampleApp());
}

class StreamBuilderExampleApp extends StatelessWidget {
  const StreamBuilderExampleApp({super.key});

  static const Duration delay = Duration(seconds: 1);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StreamBuilderExample(delay: delay),
    );
  }
}

class StreamBuilderExample extends StatefulWidget {
  const StreamBuilderExample({super.key, required this.delay});

  final Duration delay;

  @override
  State<StreamBuilderExample> createState() => _StreamBuilderExampleState();
}

class _StreamBuilderExampleState extends State<StreamBuilderExample> {
  late final StreamController<int> _controller = StreamController<int>(
    onListen: () async {
      for (var i = 0; i < 10; ++i) {
        await Future<void>.delayed(widget.delay);
        if (!_controller.isClosed) {
          _controller.add(i + 1);
        }
      }
      if (!_controller.isClosed) {
        _controller.close();
      }
    },
  );

  Stream<int> get _bids => _controller.stream;

  @override
  void dispose() {
    if (!_controller.isClosed) {
      _controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.displayMedium!,
      textAlign: TextAlign.center,
      child: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: BidsStatus(bids: _bids),
      ),
    );
  }
}

class BidsStatus extends StatelessWidget {
  const BidsStatus({super.key, required this.bids});

  final Stream<int> bids;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: bids,
      builder: (context, snapshot) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: switch (snapshot) {
            AsyncSnapshot(:final error?, :final stackTrace) => [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text('Error: $error'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Stack trace: $stackTrace',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            AsyncSnapshot(
              connectionState: ConnectionState.active,
              :final data?,
            ) =>
              [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text('Bid: \$$data'),
                ),
              ],
            AsyncSnapshot(connectionState: ConnectionState.done) => [
              const Icon(Icons.info, color: Colors.blue, size: 60),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  snapshot.hasData
                      ? 'Auction ended. Winning bid: \$${snapshot.data}'
                      : 'Auction ended with no bids.',
                ),
              ),
            ],
            _ => [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              const Text('Awaiting bids...'),
            ],
          },
        );
      },
    );
  }
}
