using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CombineTage
{
    class Program
    {
        static void Main(string[] args)
        {

            new Program().Run();
        }

        public void Run()
        {
            var w = 26;
            var count = 31;
            var dest = new Bitmap(count * w, 27);
            var g = Graphics.FromImage(dest);
            for (var i = 1; i <= count; i++)
            {
                var bmp = Bitmap.FromFile(@"..\..\..\..\Tag" + i + ".png");
                var x = (i - 1) * w;
                g.DrawImage(bmp, new Point(x, 0));
            }
            g.Dispose();
            dest.Save(@"..\..\..\..\tage.png", ImageFormat.Png);
        }
    }
}
