import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum ButtonType { FlatButton, RaisedButton }
enum LoadingBtnAnimateState { Fix, Loading, Success, Error, Timeout }

const Duration _defaultActionTimeout = Duration(seconds: 10);
const Duration _defaultResultStateDuration = Duration(seconds: 4);

class FormNotValidException implements Exception {}

class LoadingButton extends StatefulWidget {
  final String text;
  final String successText;
  final String errorText;
  final String timeoutText;
  final AsyncValueGetter action;
  final ValueSetter successAction;
  final ValueSetter errorAction;
  final VoidCallback timeoutAction;
  final Duration actionTimeout;
  final Duration resultStateDuration;
  final ButtonType buttonType;

  LoadingButton({
    @required this.text,
    @required this.action,
    this.actionTimeout = _defaultActionTimeout,
    this.resultStateDuration = _defaultResultStateDuration,
    this.buttonType = ButtonType.FlatButton,
    this.successText = "",
    this.errorText = "",
    this.timeoutText = "Délai d'attente dépassé",
    this.successAction,
    this.errorAction,
    this.timeoutAction,
  });

  @override
  State createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  LoadingBtnAnimateState _state = LoadingBtnAnimateState.Fix;
  bool _timeout = false;
  Timer _timer;


  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _getButtonChild() {
    if (_state == LoadingBtnAnimateState.Fix) {
      return Text(widget.text);
    } else if (_state == LoadingBtnAnimateState.Loading) {
      return SizedBox(
        child: CircularProgressIndicator(strokeWidth: 2),
        height: 20,
        width: 20,
      );
    } else if (_state == LoadingBtnAnimateState.Success) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                child: Icon(Icons.check, color: Colors.green),
                padding: EdgeInsets.only(right: 10)),
            Text(widget.successText,
                style: TextStyle(color: Colors.green, fontSize: 16))
          ]);
    } else if (_state == LoadingBtnAnimateState.Timeout) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                child: Icon(Icons.timer, color: Colors.red),
                padding: EdgeInsets.only(right: 10)),
            Text(widget.timeoutText, style: TextStyle(color: Colors.red, fontSize: 16))
          ]);
    } else {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                child: Icon(Icons.error, color: Colors.red),
                padding: EdgeInsets.only(right: 10)),
            Text(widget.errorText, style: TextStyle(color: Colors.red, fontSize: 16))
          ]);
    }
  }

  _setStateOver(LoadingBtnAnimateState resultState) {
    setState(() {
      _state = resultState;
    });
    _timer = Timer(widget.resultStateDuration, () {
      setState(() {
        _state = LoadingBtnAnimateState.Fix;
      });
    });
  }

  _onPressed() {
    _timeout = false;
    setState(() {
      _state = LoadingBtnAnimateState.Loading;
    });

    widget.action().then((val) {
      if (!_timeout) {
        if (widget.successAction != null) {
          widget.successAction(val);
          _setStateOver(LoadingBtnAnimateState.Fix);
        } else {
          _setStateOver(LoadingBtnAnimateState.Success);
        }
      }
    }).catchError((error) {
      if (!_timeout) {
        if (error is FormNotValidException) {
          _setStateOver(LoadingBtnAnimateState.Fix);
        } else if (widget.errorAction != null) {
          widget.errorAction(error);
          _setStateOver(LoadingBtnAnimateState.Fix);
        } else {
          _setStateOver(LoadingBtnAnimateState.Error);
        }
      }
    }).timeout(widget.actionTimeout, onTimeout: () {
      _timeout = true;
      if (widget.timeoutAction != null) {
        widget.timeoutAction();
        _setStateOver(LoadingBtnAnimateState.Fix);
      } else {
        print('TIMEOUT !!!');
        _setStateOver(LoadingBtnAnimateState.Timeout);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buttonType == ButtonType.FlatButton) {
      return FlatButton(
        child: _getButtonChild(),
        onPressed: _state == LoadingBtnAnimateState.Fix ? _onPressed : null,
      );
    } else {
      return RaisedButton(
        child: _getButtonChild(),
        color: Theme.of(context).primaryColor,
        textColor: Theme.of(context).secondaryHeaderColor,
        disabledColor: Colors.grey,
        onPressed: _state == LoadingBtnAnimateState.Fix ? _onPressed : null,
      );
    }
  }
}
