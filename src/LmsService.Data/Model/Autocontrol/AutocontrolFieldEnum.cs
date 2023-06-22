using System.ComponentModel.DataAnnotations;

namespace LmsService.Data.Model.Autocontrol
{
    public class AutocontrolFieldEnum
    {
        [Key]
        public int nACFId { get; set; }

        public int nEnumValue { get; set; }

        public string szEnumValue { get; set; }
    }
}
