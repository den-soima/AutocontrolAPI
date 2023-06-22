using System;

namespace LmsService.Data.Model.Report
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
        public decimal Vacio { get; set; }
        public decimal Llenadora { get; set; }
        public decimal Lleno { get; set; }
        public decimal Vacio1h { get; set; }
        public decimal Llenadora1h { get; set; }
        public decimal Lleno1h { get; set; }
        public decimal UP { get; set; }
        public decimal O2 { get; set; }
        public decimal CO2 { get; set; }
        public decimal AguaBlanda { get; set; }
        public decimal AguaFria { get; set; }
        public string FormatUnit { get; set; }
        public string CapacityUnit { get; set; }
        public string SKUUnit { get; set; }

        public decimal BBT { get; set; }
        public decimal Semana { get; set; }
        public decimal Turno { get; set; }

    }
}
