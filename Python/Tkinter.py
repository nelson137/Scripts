from tkinter import END, Entry, Frame, Label, Listbox, Tk
from tkinter.constants import *

class App(Tk):
    """Demonstrate concepts in tkinter."""

	def __init__(self):
		super().__init__()
		self.protocol('WM_DELETE_WINDOW', self.onExit) # override onExit

		self.synced_listboxes()
		self.multiselect_synced_listboxes()
		self.entry_validation()

	def synced_listboxes(self):
		"""Create two Listboxes whose selected items are synced."""

		def syncedSelect(e):
			index = e.widget.curselection()[0]
			for lb in lbs:
				lb.select_clear(0, END)
				lb.select_set(index)

		wrapper = Frame(self)
		wrapper.pack()

		label = Label(wrapper, text='Synced Listboxes')
        label.grid(row=0, column=0, columnspan=2)

		lb1 = Listbox(wrapper, exportselection=False)
		lb1.bind('<<ListboxSelect>>', lambda e: syncedSelect(e))
		lb1.insert(0, *range(1, 6))
		lb1.grid(row=1, column=0)

		lb2 = Listbox(wrapper, exportselection=False)
		lb2.bind('<<ListboxSelect>>', lambda e: syncedSelect(e))
		lb2.insert(0, *['a', 'b', 'c', 'd', 'e'])
		lb2.grid(row=1, column=1)

		lbs = [lb1, lb2]

	def multiselect_synced_listboxes(self):
		"""Create two Listboxes in selectmode
        MULTIPLE whose selected items are synced.
        """

		def multiSyncedSelect(e):
			for lb in lbs:
				if lb != e.widget:
					lb.select_clear(0, END)
					for cs in e.widget.curselection():
						lb.select_set(cs)

		wrapper = Frame(self)
		wrapper.pack()

		label = Label(wrapper, text='Multi-Select Synced Listboxes')
        label.grid(row=0, column=0, columnspan=2)

		lb1 = Listbox(wrapper, selectmode=MULTIPLE, exportselection=False)
		lb1.bind('<<ListboxSelect>>', lambda e: multiSyncedSelect(e))
		lb1.insert(0, *range(1, 6))
		lb1.grid(row=1, column=0)

		lb2 = Listbox(wrapper, selectmode=MULTIPLE, exportselection=False)
		lb2.bind('<<ListboxSelect>>', lambda e: multiSyncedSelect(e))
		lb2.insert(0, *['a', 'b', 'c', 'd', 'e'])
		lb2.grid(row=1, column=1)

		lbs = [lb1, lb2]

	def entry_validation(self):
        """Create an entry that will only accept numeric input."""

		def onValidate(S):
			if S in '0123456789':
				return True
			return False
		def onBad(S):
			print('Invalid input:', S)

		wrapper = Frame(self)
		wrapper.pack()

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

	def onExit(self):
		"""Perform tasks when the application is exited."""

		print('Quitting application...')
		self.destroy()

if __name__ == '__main__':
	App().mainloop()
