from tkinter import Canvas, END, Entry, Frame, Label, Listbox, Scrollbar, Tk
from tkinter.constants import *


class Scrollframe(Frame):
    """A pure Tkinter scrollable frame that actually works!
    * Use the 'interior' attribute to place widgets inside the scrollable frame
    * Construct and pack/place/grid normally
    * This frame only allows vertical scrolling

    """
    def __init__(self, parent, *args, **kwargs):
        super().__init__(parent, *args, **kwargs)

        # create the canvas and scrollbar
        _canvas = Canvas(self, bd=0, highlightthickness=0)
        _canvas.pack(side=LEFT, fill=BOTH, expand=True)

        scrollbar = Scrollbar(self, orient=VERTICAL, command=_canvas.yview)
        scrollbar.pack(fill=Y, side=RIGHT)
        _canvas.config(yscrollcommand=scrollbar.set)

        # create create the interior frame
        self.interior = interior = Frame(_canvas)
        interior_id = _canvas.create_window(0,0, window=interior, anchor=NW)

        # track changes to the canvas and frame width and sync them,
        # also updating the scrollbar
        def _configure_interior(event):
            # update the scrollbars to match the size of the inner frame
            size = (interior.winfo_reqwidth(), interior.winfo_reqheight())
            _canvas.config(scrollregion='0 0 %s %s' % size)
            if interior.winfo_reqwidth() != _canvas.winfo_width():
                # update the canvas's width to fit the inner frame
                _canvas.config(width=interior.winfo_reqwidth())
        interior.bind('<Configure>', _configure_interior)

        def _configure_canvas(event):
            if interior.winfo_reqwidth() != _canvas.winfo_width():
                # update the interior's width to fill _canvas
                _canvas.itemconfigure(interior_id, width=_canvas.winfo_width())
        _canvas.bind('<Configure>', _configure_canvas)


class App(Tk):
    """Demonstrate concepts in tkinter."""

    def __init__(self):
        super().__init__()
        self.protocol('WM_DELETE_WINDOW', self.onExit) # override onExit

        self.entry_validation()
        self.synced_listboxes()
        self.multiselect_synced_listboxes()
        self.scroll_frame()

    def entry_validation(self):
        """Create an entry that will only accept numeric input."""

        def onValidate(S):
            if S in '0123456789':
                return True
            return False
        def onBad(S):
            print('Invalid input:', S)

        wrapper = Frame(self)
        wrapper.pack(fill=BOTH, expand=True)

        label = Label(wrapper, text='Numeric Input Only')
        label.pack()

        vcmd = (self.register(onValidate), '%S')
        invcmd = (self.register(onBad), '%S')
        Entry(wrapper, validate='key', vcmd=vcmd, invcmd=invcmd).pack()

        """
        Callback substitution codes:
        +------+--------------------------------------------------------------+
        | '%d' | 0 for an attempted deletion, 1 for an attempted insertion,   |
        |      | or -1 if the callback was called for focus in, focus out,    |
        |      | or a change to the textvariable.                             |
        +------+--------------------------------------------------------------+
        | '%i' | The index of the beginning of the attempted insertion or     |
        |      | deletion. -1 if the callback was due to focus in, focus out, |
        |      | or a change to the textvariable.                             |
        +------+--------------------------------------------------------------+
        | '%P' | The value that the text will have if the change is allowed.  |
        +------+--------------------------------------------------------------+
        | '%s' | The text in the entry before the change.                     |
        +------+--------------------------------------------------------------+
        | '%S' | The text of the insertion or deletion.                       |
        +------+--------------------------------------------------------------+
        | '%v' | The current value of the entry's validate option.            |
        +------+--------------------------------------------------------------+
        | '%V' | The reason for this callback: 'focusin', 'focusout', 'key',  |
        |      | or 'forced' if the textvariable was changed.                 |
        +------+--------------------------------------------------------------+
        | '%W' | The name of the widget.                                      |
        +------+--------------------------------------------------------------+
        """

    def synced_listboxes(self):
        """Create two Listboxes whose selected items are synced."""

        def synced_select(e):
            index = e.widget.curselection()[0]
            for lb in lbs:
                lb.select_clear(0, END)
                lb.select_set(index)

        wrapper = Frame(self)
        wrapper.pack(fill=BOTH, expand=True)

        label = Label(wrapper, text='Synced Listboxes')
        label.grid(row=0, column=0, columnspan=2)

        lb1 = Listbox(wrapper, exportselection=False)
        lb1.bind('<<ListboxSelect>>', synced_select)
        lb1.insert(0, *range(1, 6))
        lb1.grid(row=1, column=0)

        lb2 = Listbox(wrapper, exportselection=False)
        lb2.bind('<<ListboxSelect>>', synced_select)
        lb2.insert(0, *['a', 'b', 'c', 'd', 'e'])
        lb2.grid(row=1, column=1)

        lbs = [lb1, lb2]

    def multiselect_synced_listboxes(self):
        """Create two Listboxes in selectmode
        MULTIPLE whose selected items are synced.
        """

        def multi_synced_select(e):
            for lb in lbs:
                if lb != e.widget:
                    lb.select_clear(0, END)
                    for cs in e.widget.curselection():
                        lb.select_set(cs)

        wrapper = Frame(self)
        wrapper.pack(fill=BOTH, expand=True)

        label = Label(wrapper, text='Multi-Select Synced Listboxes')
        label.grid(row=0, column=0, columnspan=2)

        lb1 = Listbox(wrapper, selectmode=MULTIPLE, exportselection=False)
        lb1.bind('<<ListboxSelect>>', multi_synced_select)
        lb1.insert(0, *range(1, 6))
        lb1.grid(row=1, column=0)

        lb2 = Listbox(wrapper, selectmode=MULTIPLE, exportselection=False)
        lb2.bind('<<ListboxSelect>>', multi_synced_select)
        lb2.insert(0, *['a', 'b', 'c', 'd', 'e'])
        lb2.grid(row=1, column=1)

        lbs = [lb1, lb2]

    def scroll_frame(self):
        """Create a Scrollable Frame."""

        wrapper = Frame(self)
        wrapper.pack(fill=BOTH, expand=True)

        label = Label(wrapper, text='Scrollable Frame')
        label.pack()

        frame = Scrollframe(wrapper, width=182, height=172, relief=GROOVE, bd=1)
        frame.pack()

        for r in range(1, 21):
            texts = ['text', r, '..........']
            for c in range(len(texts)):
                Label(frame.interior, text=texts[c]).grid(row=r, column=c)

    def onExit(self):
        """Perform tasks when the application is exited."""

        print('Quitting application...')
        self.destroy()

    def mainloop(self):
        self.lift()
        self.attributes('-topmost', True)
        self.after_idle(self.attributes, '-topmost', False)
        super().mainloop()


if __name__ == '__main__':
    App().mainloop()

