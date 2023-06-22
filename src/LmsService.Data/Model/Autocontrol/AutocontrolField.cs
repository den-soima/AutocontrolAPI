using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;

namespace LmsService.Data.Model.Autocontrol
{
    public class AutocontrolField
    {
        [Key]
        public int nKey { get; set; }

        public int nKeyAC { get; set; }

        public int nDataXLinkAutoControlField { get; set; }    
       
        public decimal rMinValue { get; set; }

        public decimal rMaxValue { get; set; }      

        public string szValue { get; set; }

        public int nUserLink { get; set; }

        public DateTime tDataMeasured { get; set; }

        public DateTime tLastUpdated { get; set; }

        public bool bDeleted { get; set; }
    }
}
