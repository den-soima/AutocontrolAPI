using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using LmsService.Data.Model.Autocontrol;
using Microsoft.AspNetCore.Http;

namespace LmsService.Data
{
    public interface IAutocontrolRepository
    {
        IQueryable<Autocontrol> GetAutocontrols(string szPiTBaseUserUid);

        IQueryable<AutocontrolDialog> GetDialogFieldsByACId(int nKeyAC);

        IQueryable<AutocontrolFieldEnum> GetEnumsByFieldId(int nACFId);

        int UpdateAutocontrolField(AutocontrolField field);


        Task<long> CreateAutocontrolFile(int nACFId, IFormFile file, string lmsFolderPath, string fileName);
    }
} 