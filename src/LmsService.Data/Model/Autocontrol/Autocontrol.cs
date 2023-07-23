using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace LmsService.Data.Model.Autocontrol
{
    public class Autocontrol
    {
        [Key]
        public int nACId { get; set; }        

        public string szLineName { get; set; }
        public string szACName { get; set; }

        public string szArea { get; set; }

        public int nStatus { get; set; }
        public string szStatus { get; set; }

        public string szComment { get; set; }

        public DateTime tLastModified { get; set; }

    }
}
