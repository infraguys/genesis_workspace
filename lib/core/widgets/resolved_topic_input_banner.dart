import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ResolvedTopicInputBanner extends StatelessWidget {
  const ResolvedTopicInputBanner({
    super.key,
    required this.onUnresolvePressed,
    this.isLoading = false,
  });

  final Future<void> Function() onUnresolvePressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outline.withValues(alpha: .1);

    return SizedBox(
      height: 60.0,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BoxBorder.fromLTRB(
            top: BorderSide(color: borderColor),
          ),
        ),
        child: Padding(
          padding: const .symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: .center,
            children: [
              Expanded(
                child: RichText(
                  textAlign: .center,
                  text: TextSpan(
                    text: 'Это тема решена. ',
                    children: [
                      TextSpan(
                        text: 'Снимите отметку,',
                        style: TextStyle(
                          color: Colors.orange,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print('clicked');
                          },
                      ),
                      TextSpan(text: ' чтобы отправить сообщение'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
