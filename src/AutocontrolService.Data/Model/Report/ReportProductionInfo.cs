using System;
using System.Collections.Generic;
using System.Text;

namespace AutocontrolService.Data.Model.Report
{
    public class ReportProductionInfo
    {
        public Int64 nRatedCapacity { get; set; }
        public Int64 nNominalProduction { get; set; }
        public decimal rShiftPercentage { get; set; }
        public Int64 ActualProductionCaj { get; set; }
        public Int64 ActualProduction { get; set; }
        public int ActualProduction1h { get; set; }
        public decimal RatioOfCurrentShiftDuration { get; set; }
        public Int64 Vacio { get; set; }
        public Int64 Llenadora { get; set; }
        public Int64 Lleno { get; set; }
        public int Vacio1h { get; set; }
        public int Llenadora1h { get; set; }
        public int Lleno1h { get; set; }
        public decimal UP { get; set; }
        public decimal O2 { get; set; }
        public decimal CO2 { get; set; }
        public decimal AguaBlanda { get; set; }
        public decimal AguaFría { get; set; }
        public string FormatUnit { get; set; }
        public string CapacityUnit { get; set; }
        public string SKUUnit { get; set; }
    }
}
