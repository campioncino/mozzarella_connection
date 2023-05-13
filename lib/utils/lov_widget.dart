import 'dart:async';

import 'package:flutter/material.dart';

typedef void OnSelectedCallback(dynamic selected);
typedef void OnRemovedCallback();

class LovWidget<T> extends StatelessWidget {
  final dynamic? object;
  @deprecated
  final String? title;
  final Widget Function(T? val)? headerFunction;
  @deprecated
  final String? titleField;
  @deprecated
  final String? subtitleField;
  final String? optionField;
  final Widget Function(T? val)? titleFunction;
  final Widget Function(T? val)? subtitleFunction;
  final Widget Function(T? val)? optionFunction;
  final Widget? builder;
  final OnSelectedCallback? onSelected;
  final OnRemovedCallback? onRemoved;
  final bool enabled;
  final bool flat;

  LovWidget(
      {Key? key,
        this.object,
        this.title,
        this.headerFunction,
        this.titleField,
        this.subtitleField,
        this.optionField,
        this.titleFunction,
        this.subtitleFunction,
        this.optionFunction,
        @required this.builder,
        @required this.onSelected,
        this.onRemoved,
        this.enabled = true,
        this.flat = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(0.0),
        elevation: this.flat ? 0.0 : 2.0,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _createTitleHeader(context),
                    _createTitleField(context),
                    _createSubtitleField(context),
                    _createOptionFunction(context),
                  ],
                ),
              )),
          _createButton(context),
        ]));
  }

  _createButton(BuildContext context) {
    if (this.onRemoved == null) {
      return Container(
        child: TextButton(
          child: Text("SELEZIONA",
              textScaleFactor: 0.9, style: buttonStyle()),
          onPressed: enabled ? () => _onSelectPressed(context) : null,
        ),
      );
    } else {
      if (this.object == null) {
        return Container(
          child: TextButton(
            child: Text("SELEZIONA",
                textScaleFactor: 0.9,
                style: buttonStyle()),
            onPressed: enabled ? () => _onSelectPressed(context) : null,
          ),
        );
      } else {
        return Container(
          child: TextButton(
            child: Text(
                "RIMUOVI",
                textScaleFactor: 0.9,
                style: buttonStyle()),
            onPressed: enabled ? () => _onRemovePressed() : null,
          ),
        );
      }
    }
  }

  TextStyle buttonStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      /// non dovrebbe essere necessario perchè è un comportamento normale
      // color: enabled ? Colors.black : Colors.grey
    );

  }

  _onSelectPressed(BuildContext context) async {
    var selected = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => this.builder!));
    if (selected != null) {
      this.onSelected!(selected);
    }
  }

  _onRemovePressed() async {
    this.onRemoved!();
  }

  _createSubtitleField(BuildContext context) {
    if (this.subtitleFunction != null) {
      return this.subtitleFunction!(this.object);
    }

    if (this.subtitleField == null) {
      return new Container();
    }

    if (this.object == null) {
      return new Container();
    }

    return Text(
      this.object != null ? '${this.object.toJson()[this.subtitleField]}' : '',
      style: new TextStyle(
        fontSize: 15.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  _createOptionFunction(BuildContext context){
    if(this.optionFunction != null){
      return this.optionFunction!(this.object);
    }
    if(this.optionFunction == null){
      return Container();
    }
    if(this.object == null){
      return Container();
    }
    return Text(
      this.object != null ? '${this.object.toJson()[this.optionField]}' : '',
      style: new TextStyle(
        fontSize: 15.0,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  _createTitleHeader(BuildContext context) {
    if (this.title == null && this.headerFunction == null) {
      return Text('HEADER_TITLE');
    }

    if (this.headerFunction != null) {
      return this.headerFunction!(this.object);
    }
    return Text(
      this.title!,
      maxLines: 3,
      style: TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
        // color: Colors.black54,
      ),
    );
  }

  _createTitleField(BuildContext context) {
    if (this.object == null && this.title != null) {
      return Text(
          'SELEZIONA ${this.title}');
    }

    if (this.titleFunction != null) {
      return this.titleFunction!(this.object);
    }

    return Text(
      '${this.object.toJson()[this.titleField]}',
      style: new TextStyle(
        fontSize: 16.0,
        fontStyle: FontStyle.normal,
      ),
    );
  }
}
