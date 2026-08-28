#!/usr/bin/env python3
"""
Daimon Bar — Floating command interface to the Fifth
L7 Way: minimal, on-device, always available, no external deps.
"""

import tkinter as tk
from tkinter import ttk
import subprocess
import threading
import os

class DaimonBar:
    def __init__(self, root):
        self.root = root
        self.root.title("The Fifth")
        self.root.attributes("-topmost", True)
        self.root.attributes("-alpha", 0.92)
        self.root.configure(bg="#0a0a0a")
        
        # Make it float like a HUD
        self.root.overrideredirect(True)
        self.root.geometry("420x120+100+80")
        
        self.style = ttk.Style()
        self.style.configure("TEntry", fieldbackground="#111", foreground="#ddd", font=("Menlo", 11))
        
        self.frame = tk.Frame(root, bg="#0a0a0a", padx=12, pady=10)
        self.frame.pack(fill="both", expand=True)
        
        self.label = tk.Label(self.frame, text="👁 The Fifth", fg="#4a9eff", bg="#0a0a0a", font=("Menlo", 10, "bold"))
        self.label.pack(anchor="w")
        
        self.entry = ttk.Entry(self.frame, width=48)
        self.entry.pack(fill="x", pady=6)
        self.entry.bind("<Return>", self.send_message)
        self.entry.bind("<Escape>", lambda e: self.root.withdraw())
        
        self.response = tk.Label(self.frame, text="—", fg="#888", bg="#0a0a0a", font=("Menlo", 9), wraplength=390, justify="left")
        self.response.pack(anchor="w")
        
        # Drag to move
        self.frame.bind("<Button-1>", self.start_move)
        self.frame.bind("<B1-Motion>", self.do_move)
        
        self.x = 0
        self.y = 0
        
    def start_move(self, event):
        self.x = event.x
        self.y = event.y
        
    def do_move(self, event):
        new_x = self.root.winfo_x() + (event.x - self.x)
        new_y = self.root.winfo_y() + (event.y - self.y)
        self.root.geometry(f"+{new_x}+{new_y}")
        
    def send_message(self, event=None):
        msg = self.entry.get().strip()
        if not msg:
            return
        self.entry.delete(0, "end")
        self.response.config(text="…thinking…", fg="#666")
        
        def worker():
            try:
                result = subprocess.run(
                    ["./daimon.sh", "commune", msg],
                    capture_output=True, text=True, cwd=os.path.dirname(__file__)
                )
                output = result.stdout.strip() or result.stderr.strip() or "—"
                self.root.after(0, lambda: self.response.config(text=output[:280], fg="#4a9eff"))
            except Exception as e:\n                self.root.after(0, lambda: self.response.config(text=str(e), fg="#ff6b6b"))
        
        threading.Thread(target=worker, daemon=True).start()

if __name__ == "__main__":
    root = tk.Tk()
    app = DaimonBar(root)
    root.mainloop()
