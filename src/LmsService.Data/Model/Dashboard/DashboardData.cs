using System;
using System.Collections.Generic;
using System.Text;

namespace LmsService.Data.Model.Dashboard
{
    public class DashboardData
    {
        public Int64 TopPercent { get; set; }
        public Int64 nCurrentMachineState { get; set; }
        public string szCurrentMachineState { get; set; }
        public string szColorCurrentMachineState { get; set; }
        public Int64 nCurrentMachineState2 { get; set; }
        public string szCurrentMachineState2 { get; set; }
        public string szColorCurrentMachineState2 { get; set; }
        public decimal RatioOfCurrentShiftDuration { get; set; }
        public int nDataXLinkLine { get; set; }
        public int nShiftKey { get; set; }
        public string szMachine { get; set; }
        public decimal nShiftPercent { get; set; }
        public int nEstimatedShift { get; set; }
        public decimal nObjEff { get; set; }
        public string szCurrentOrder { get; set; }
        public string szFormat { get; set; }
        public decimal nRatedCapacity { get; set; }
        public decimal GoodQty { get; set; }
        public int FullInspector { get; set; }
        public int EmptyInspector { get; set; }
        public decimal WaterQty { get; set; }
        public int nTank1 { get; set; }
        public int nTank2 { get; set; }
        public decimal nVolTank1 { get; set; }
        public decimal WaterRate { get; set; }
        public Int64 secProductionTime { get; set; }        
    }
}
