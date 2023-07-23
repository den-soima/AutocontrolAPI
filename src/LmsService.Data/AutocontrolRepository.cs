using System;
using System.Linq;
using LmsService.Data.Services;
using LmsService.Data.Model.Autocontrol;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using System.Data;
using Microsoft.AspNetCore.Http;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace LmsService.Data
{
    class AutocontrolRepository : IAutocontrolRepository
    {

        private LmsContext _context;

        public AutocontrolRepository(LmsContext context)
        {
            _context = context;
        }
        public IQueryable<Autocontrol> GetAutocontrols(string szPiTBaseUserUid)
        {

            var nKey = new SqlParameter("@nKey", SqlDbType.Int);
            var nStatus = new SqlParameter("@nStatus", SqlDbType.Int);
            var nUserLink = new SqlParameter("@nUserLink", SqlDbType.Int);
            var nLanguageId = new SqlParameter("nLanguageId", SqlDbType.Int);
            var szPiTBaseUser = new SqlParameter("@szPiTBaseUser", SqlDbType.NVarChar);

            nKey.Value = DBNull.Value;
            nStatus.Value = DBNull.Value;
            nUserLink.Value = DBNull.Value;
            nLanguageId.Value = 10;
            if (String.IsNullOrWhiteSpace(szPiTBaseUserUid))
                szPiTBaseUser.Value = DBNull.Value;
            else
                szPiTBaseUser.Value = szPiTBaseUserUid;

            var value = _context.Autocontrols.FromSqlRaw<Autocontrol>($"EXECUTE [zmod].[sp_LmsAutoControlGet] @nKey, @nStatus, @nUserLink, @nLanguageId, @szPiTBaseUser",
                parameters: new[] { nKey, nStatus, nUserLink, nLanguageId, szPiTBaseUser });
            //var value = _context.Autocontrols.FromSqlRaw<Autocontrol>($"EXECUTE [zmod].[sp_LmsAutoControlGet] @szPiTBaseUser={szPiTBaseUserUid}");

            return value;
        }

        public IQueryable<AutocontrolDialog> GetDialogFieldsByACId(int nKeyAC)
        {
            var value = _context.AutocontrolDialog.FromSqlRaw<AutocontrolDialog>($"EXECUTE [zmod].[sp_LmsAutoControlFieldsGet] {nKeyAC}");
            return value;
        }

        public IQueryable<AutocontrolFieldEnum> GetEnumsByFieldId(int nACFId)
        {
            var value = _context.AutocontrolFieldEnums.FromSqlRaw<AutocontrolFieldEnum>($"EXECUTE [zmod].[sp_LmsAutoControlFieldsEnumGet] {nACFId}");
            return value;
        }

        public int UpdateAutocontrolField(AutocontrolField field)
        {
            var nKey = new SqlParameter("@nKey", SqlDbType.Int);
            var nKeyAC = new SqlParameter("@nKeyAC", SqlDbType.Int);
            var nDataXLinkAutoControlField = new SqlParameter("@nDataXLinkAutoControlField", SqlDbType.Int);
            var rMaxValue = new SqlParameter("@rMaxValue", SqlDbType.Float);
            var rMinValue = new SqlParameter("@rMinValue", SqlDbType.Float);
            var szValue = new SqlParameter("@szValue", SqlDbType.NVarChar);
            var nUserLink = new SqlParameter("@nUserLink", SqlDbType.Int);
            var tDataMeasured = new SqlParameter("@tDataMeasured", SqlDbType.BigInt);
            var tLastUpdated = new SqlParameter("@tLastUpdated", SqlDbType.BigInt);
            var bDeleted = new SqlParameter("@bDeleted", SqlDbType.Bit);
            var szPiTBaseUser = new SqlParameter("@szPiTBaseUser", SqlDbType.NVarChar);

            nKey.Value = field.nKey;
            nKeyAC.Value = DBNull.Value;
            nDataXLinkAutoControlField.Value = DBNull.Value;
            rMaxValue.Value = DBNull.Value;
            rMinValue.Value = DBNull.Value;
            szValue.Value = field.szValue;
            nUserLink.Value = DBNull.Value;
            tDataMeasured.Value = DBNull.Value;
            tLastUpdated.Value = DBNull.Value;
            bDeleted.Value = false;
            szPiTBaseUser.Value = field.szPiTBaseUserUid;

            var rowAffected = _context.Database.ExecuteSqlRaw($"EXECUTE [zmod].[sp_LmsAutoControlFieldsWrite] @nKey, @nKeyAC, @nDataXLinkAutoControlField, @rMaxValue, @rMinValue, @szValue, @nUserLink, @tDataMeasured, @tLastUpdated, @bDeleted, @szPiTBaseUser",
                    parameters: new[] { nKey, nKeyAC, nDataXLinkAutoControlField, rMaxValue, rMinValue, szValue, nUserLink, tDataMeasured, tLastUpdated, bDeleted, szPiTBaseUser });

            // var rowAffected = _context.Database.ExecuteSqlInterpolated($"EXECUTE [zmod].[sp_LmsAutoControlFieldsWrite] @nKey ={field.nKey}, @szValue={field.szValue}");

            return rowAffected;
        }

        public async Task<long> CreateAutocontrolFile(int nACFId, IFormFile file, string lmsFolderPath, string fileName)
        {
            DateTime today = DateTime.UtcNow.Date;
            string dateFolderName = today.Year.ToString() + "-" + (today.Month < 10 ? "0" + today.Month.ToString() : today.Month.ToString()) + "-" + today.Day.ToString();

            string lineIdFolderName = nACFId.ToString();

            string fullPath = Path.Combine(lmsFolderPath, dateFolderName, lineIdFolderName);

            if (!Directory.Exists(fullPath))
                Directory.CreateDirectory(fullPath);

            var filePath = fullPath + "\\" + fileName;

            using (var fileStream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(fileStream);
            }

            long size = new FileInfo(filePath).Length;

            return size;
        }


    }

}
