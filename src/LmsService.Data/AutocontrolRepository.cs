using System;
using System.Linq;
using LmsService.Data.Services;
using LmsService.Data.Model.Autocontrol;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using System.Data;

namespace LmsService.Data
{
    class AutocontrolRepository : IAutocontrolRepository
    {

        private LmsContext _context;

        public AutocontrolRepository(LmsContext context)
        {
            _context = context;
        }
        public IQueryable<Autocontrol> GetAutocontrols()
        {
            var value = _context.Autocontrols.FromSqlRaw<Autocontrol>("EXECUTE [zmod].[sp_LmsAutoControlGet]");
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

            var rowAffected = _context.Database.ExecuteSqlRaw($"EXECUTE [zmod].[sp_LmsAutoControlFieldsWrite] @nKey, @nKeyAC, @nDataXLinkAutoControlField, @rMaxValue, @rMinValue, @szValue, @nUserLink, @tDataMeasured, @tLastUpdated, @bDeleted",
                    parameters: new[] { nKey, nKeyAC, nDataXLinkAutoControlField, rMaxValue, rMinValue, szValue, nUserLink, tDataMeasured, tLastUpdated, bDeleted });

            // var rowAffected = _context.Database.ExecuteSqlInterpolated($"EXECUTE [zmod].[sp_LmsAutoControlFieldsWrite] @nKey ={field.nKey}, @szValue={field.szValue}");

            return rowAffected;
        }
    }

}
