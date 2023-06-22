using System.Linq;
using LmsService.Data.Model.Autocontrol;

namespace LmsService.Data
{
    public interface IAutocontrolRepository
    {
        IQueryable<Autocontrol> GetAutocontrols();

        IQueryable<AutocontrolDialog> GetDialogFieldsByACId(int nKeyAC);

        IQueryable<AutocontrolFieldEnum> GetEnumsByFieldId(int nACFId);

        int UpdateAutocontrolField(AutocontrolField field);

    }
} 