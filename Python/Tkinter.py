from tkinter import Tk, Frame, Label, Listbox, END, MULTIPLE

class App(Tk):
	def __init__(self):
		super().__init__()
		self.protocol('WM_DELETE_WINDOW', self.onExit) # override onExit

		self.synced_listboxes()
		self.multiselect_synced_listboxes()

	def synced_listboxes(self):
		"""Create two Listboxes whose selected items are synced."""

		def syncedSelect(e):
			index = e.widget.curselection()[0]
			for lb in lbs:
				lb.select_clear(0, END)
				lb.select_set(index)

		wrapper = Frame(self)
		wrapper.pack()

		Label(wrapper, text='Synced Listboxes').grid(row=0, column=0, columnspan=2)

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
		"""Create two Listboxes in selectmode MULTIPLE whose selected items are synced."""

		def multiSyncedSelect(e):
			for lb in lbs:
				if lb != e.widget:
					lb.select_clear(0, END)
					for cs in e.widget.curselection():
						lb.select_set(cs)

		wrapper = Frame(self)
		wrapper.pack()

		Label(wrapper, text='Multi-Select Synced Listboxes').grid(row=0, column=0, columnspan=2)

		lb1 = Listbox(wrapper, selectmode=MULTIPLE, exportselection=False)
		lb1.bind('<<ListboxSelect>>', lambda e: multiSyncedSelect(e))
		lb1.insert(0, *range(1, 6))
		lb1.grid(row=1, column=0)

		lb2 = Listbox(wrapper, selectmode=MULTIPLE, exportselection=False)
		lb2.bind('<<ListboxSelect>>', lambda e: multiSyncedSelect(e))
		lb2.insert(0, *['a', 'b', 'c', 'd', 'e'])
		lb2.grid(row=1, column=1)

		lbs = [lb1, lb2]

	def onExit(self):
		"""Overrides tkinter's onExit."""

		print('Quitting application...')
		self.destroy()

if __name__ == '__main__':
	App().mainloop()
