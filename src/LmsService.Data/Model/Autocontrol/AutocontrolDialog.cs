using System;
using System.Collections.Generic;
using System.Text;
using System.ComponentModel.DataAnnotations;

namespace LmsService.Data.Model.Autocontrol
{
    public class AutocontrolDialog
    {
        [Key]
        public int nACFId { get; set; }

        public int nACId { get; set; }
    
        public string szACName { get; set; }

        public string szGroupName { get; set; }
   
        public string szACFieldName { get; set; }

        public int nFieldDataType { get; set; }

        public int bHasLimit { get; set; }

        public double rMinValue { get; set; }

        public double rMaxValue { get; set; }      

        public string szValue { get; set; }   
    }
}
