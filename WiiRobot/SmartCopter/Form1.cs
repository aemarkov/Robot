using System;
using System.Collections;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO.Ports;
using System.Drawing.Drawing2D;
using System.Collections.Generic;

namespace SmartCopter
{
    
    public partial class Form1 : Form
    {

        //=============== Graph data ==================
        Bitmap bmp;
        Graphics g;

        float ScaleY = 1;

        int X, Y, Xo, Yo;
        int CenterX, CenterY;
        int Yaw=0;
        //================ General ======================
        bool isReceived = false;


        SerialPort Com;

        String inS="";
        //=============== Input options ==================
        const byte NumOfParam = 3;
        //================================================
        public Form1()
        {
            InitializeComponent();
        }


        private void Form1_Load(object sender, EventArgs e)
        {
            bmp = new Bitmap(GraphBox.Width, GraphBox.Height);
            g = Graphics.FromImage(bmp);
            g.Clear(Color.White);
            GraphBox.Image = bmp;


            CenterX  = GraphBox.Width / 2;
            CenterY  = GraphBox.Height / 2;
           
            X = 0;
            Y = 0;
            Xo = 0;
            Yo = 0;

           

            Com.PortName = "COM7";
            
        }
        //***************************************************
        private void button1_Click(object sender, EventArgs e)
        {
            Com.Open();
            if (Com.IsOpen) { MessageBox.Show("Port is open"); timer1.Enabled = true; } 
        }
        //****************************************************
        private void Form1_Closing(object sender, EventArgs  e)
        {
            Com.Close();
            if (!Com.IsOpen) { timer1.Enabled = false; MessageBox.Show("Port closed"); } 
        }
        //*******************************************************
        private void Com_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {

          

            inS = Com.ReadLine();
            inS = inS.Remove(inS.Length - 1);

            if (inS.Length != 0)
            {
                if ((inS[0] == 'N') && (inS[inS.Length - 1] == 'E'))
                {
                    int[] _buf = new int[NumOfParam];


                    String _param = "";
                    inS = inS.Substring(1, inS.Length - 2);

                    int _j = 0; //Read position

                    for (byte _i = 0; _i < NumOfParam; _i++)
                    {
                        while ((inS[_j] != ' ') && (_j < inS.Length))
                        {
                            _param += inS[_j];
                            _j++;
                        }


                        _buf[_i] = Convert.ToInt32(_param);

                        _j++;
                        _param = "";

                    }

                    X = _buf[0];
                    Y = _buf[1];
                    Yaw = _buf[2];
                    isReceived = true;
                }
            }
        }

        //************************************************

        void DrawGrap()
        {

            int Scale = 5;
            g.DrawLine(new Pen(Brushes.Black),CenterX-X*Scale,CenterY-Y*Scale, CenterX-Xo*Scale, CenterY-Yo*Scale );
            Xo = X;
            Yo = Y;
            GraphBox.Image = bmp;

        }

      

        
        private void timer1_Tick(object sender, EventArgs e)
        {
            if (isReceived)
            {
                DrawGrap();
                //----------------------
               
                //----------------------
                if (LogChb.Checked)
                {
                    logBox.Text += inS + Environment.NewLine;
                    if (AutoScrollChb.Checked)
                    {
                        logBox.SelectionStart = logBox.Text.Length - 1;

                    }
                    logBox.ScrollToCaret();
                }
                isReceived = false;
            }
        }




    



       

    }

   
}
