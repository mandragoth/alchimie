/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module runa.ui.box;

import runa.ui.element;

import runa.render, runa.core;

abstract class Box : UIElement {
    float paddingX = 0f, paddingY = 0f;
    float marginX = 0f, marginY = 0f;
    float spacing = 0f;

    this() {
        isEnabled = true;
    }
}

class HBox : Box {
    override void update() {
        float x = marginX, y = paddingY;

        foreach (UIElement child; _children) {
            child.alignX = UIElement.AlignX.left;
            child.alignY = UIElement.AlignY.top;
            child.posY = marginY;
            child.posX = x;
            x += child.sizeX + spacing;
            y = max(y, child.sizeY + marginY * 2f);
        }
        x = max(paddingX, x + marginX);

        sizeX = x;
        sizeY = y;
    }
}

class VBox : Box {
    override void update() {
        float x = paddingX, y = marginY;

        foreach (UIElement child; _children) {
            child.alignX = UIElement.AlignX.left;
            child.alignY = UIElement.AlignY.top;
            child.posX = marginX;
            child.posY = y;
            y += child.sizeY + spacing;
            x = max(x, child.sizeX + marginX * 2f);
        }
        y = max(paddingY, y + marginY);

        sizeX = x;
        sizeY = y;
    }
}
