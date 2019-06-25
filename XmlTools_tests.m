classdef XmlTools_tests < matlab.unittest.TestCase
    
    properties (Constant)
        xml_file_heading = '<?xml version="1.0" encoding="utf-8"?>';
        test_xml_file_name = 'xml_test.xml';
    end
    
    methods(TestMethodSetup)
        function createObject(testCase)
        end
    end
    
    methods(TestMethodTeardown)
        function destroyObject(testCase)
            delete(XmlTools_tests.test_xml_file_name);
        end
    end

    methods (Static)
        function structure = generateXmlEmptyStructure(num_elements)
            if nargin < 1
                num_elements = 1;
            end

            structure = repmat(...
                            struct('Tag', '', 'Attributes', [], 'Data', '', 'Children', []),...
                            [1, num_elements]);
        end

        function structure = generateAttributeEmptyStructure(num_attributes)
            if nargin < 1
                num_attributes = 1;
            end

            structure = repmat(...
                struct('Name', '', 'Value', ''),...
                [1, num_attributes]);
        end
    end
    
    methods(Test)
        function should_write_xml_from_structure(testCase)
            % Given
            structure = XmlTools_tests.generateXmlEmptyStructure();
            structure.Tag = 'global_tag';
            structure.Children = XmlTools_tests.generateXmlEmptyStructure(2);
            
            structure.Children(1).Tag = 'child_element';
            structure.Children(1).Attributes = XmlTools_tests.generateAttributeEmptyStructure(2);
            structure.Children(1).Attributes(1).Name = 'attr1';
            structure.Children(1).Attributes(1).Value = 'val1';
            structure.Children(1).Attributes(2).Name = 'attr2';
            structure.Children(1).Attributes(2).Value = 'val2';
            
            structure.Children(2).Tag = 'child_element';
            structure.Children(2).Attributes = XmlTools_tests.generateAttributeEmptyStructure(1);
            structure.Children(2).Attributes(1).Name = 'attr1';
            structure.Children(2).Attributes(1).Value = 'val1';
            structure.Children(2).Children = XmlTools_tests.generateXmlEmptyStructure();
            structure.Children(2).Children.Tag = '#text';
            structure.Children(2).Children.Data = 'Hello world!';
            
            xml_expected_text = sprintf(['%s\n',...          
                '<global_tag>\n',...
                '   <child_element attr1="val1" attr2="val2"/>\n',...
                '   <child_element attr1="val1">Hello world!</child_element>\n',...
                '</global_tag>'], XmlTools_tests.xml_file_heading);

            % When
            XmlTools.structure2XML(structure, XmlTools_tests.test_xml_file_name);
            
            % Then
            xml_text = fileread(XmlTools_tests.test_xml_file_name);

            testCase.assertEqual(xml_text, xml_expected_text);
        end
        
        function should_append_to_existing_xml_from_structure(testCase)
            % Given
            xml_existing_text = sprintf(['%s\n',...          
            '<global_tag>\n',...
            '   <child_element name="exísting_child"/>\n',...
            '</global_tag>'], XmlTools_tests.xml_file_heading);

            f = fopen(XmlTools_tests.test_xml_file_name, 'w');
            fwrite(f, xml_existing_text);
            fclose(f);

            structure = XmlTools_tests.generateXmlEmptyStructure();
            structure.Tag = 'global_tag';
            structure.Children = XmlTools_tests.generateXmlEmptyStructure(2);
            
            structure.Children(1).Tag = 'child_element';
            structure.Children(1).Attributes = XmlTools_tests.generateAttributeEmptyStructure(2);
            structure.Children(1).Attributes(1).Name = 'attr1';
            structure.Children(1).Attributes(1).Value = 'val1';
            structure.Children(1).Attributes(2).Name = 'attr2';
            structure.Children(1).Attributes(2).Value = 'val2';
            
            structure.Children(2).Tag = 'child_element';
            structure.Children(2).Attributes = XmlTools_tests.generateAttributeEmptyStructure(1);
            structure.Children(2).Attributes(1).Name = 'attr1';
            structure.Children(2).Attributes(1).Value = 'val1';
            structure.Children(2).Children = XmlTools_tests.generateXmlEmptyStructure();
            structure.Children(2).Children.Tag = '#text';
            structure.Children(2).Children.Data = 'Hello world!';
            
            xml_expected_text = sprintf(['%s\n',...          
                '<global_tag>\n',...
                '   <child_element name="exísting_child"/>\n',...
                '   <child_element attr1="val1" attr2="val2"/>\n',...
                '   <child_element attr1="val1">Hello world!</child_element>\n',...
                '</global_tag>'], XmlTools_tests.xml_file_heading);

            % When
            XmlTools.structure2XML(structure, XmlTools_tests.test_xml_file_name, true);

            % Then
            xml_text = fileread(XmlTools_tests.test_xml_file_name);
    
            testCase.assertEqual(xml_text, xml_expected_text);
        end

        function should_append_to_existing_xml_from_structure_with_before_flag(testCase)
            % Given
            xml_existing_text = sprintf(['%s\n',...          
            '<global_tag>\n',...
            '   <child_element name="existing_child"/>\n',...
            '</global_tag>'], XmlTools_tests.xml_file_heading);

            f = fopen(XmlTools_tests.test_xml_file_name, 'w');
            fwrite(f, xml_existing_text);
            fclose(f);

            structure = XmlTools_tests.generateXmlEmptyStructure();
            structure.Tag = 'global_tag';
            structure.Children = XmlTools_tests.generateXmlEmptyStructure(2);
            
            structure.Children(1).Tag = 'child_element';
            structure.Children(1).Attributes = XmlTools_tests.generateAttributeEmptyStructure(2);
            structure.Children(1).Attributes(1).Name = 'attr1';
            structure.Children(1).Attributes(1).Value = 'val1';
            structure.Children(1).Attributes(2).Name = 'attr2';
            structure.Children(1).Attributes(2).Value = 'val2';
            
            structure.Children(2).Tag = 'child_element';
            structure.Children(2).Attributes = XmlTools_tests.generateAttributeEmptyStructure(1);
            structure.Children(2).Attributes(1).Name = 'attr1';
            structure.Children(2).Attributes(1).Value = 'val1';
            structure.Children(2).Children = XmlTools_tests.generateXmlEmptyStructure();
            structure.Children(2).Children.Tag = '#text';
            structure.Children(2).Children.Data = 'Hello world!';
            
            xml_expected_text = sprintf(['%s\n',...          
                '<global_tag>\n',...
                '   <child_element attr1="val1">Hello world!</child_element>\n',...
                '   <child_element attr1="val1" attr2="val2"/>\n',...
                '   <child_element name="existing_child"/>\n',...
                '</global_tag>'], XmlTools_tests.xml_file_heading);

            % When
            XmlTools.structure2XML(structure, XmlTools_tests.test_xml_file_name, true, true);

            % Then
            xml_text = fileread(XmlTools_tests.test_xml_file_name);
            
            testCase.assertEqual(xml_text, xml_expected_text);
        end
        
        function should_not_modify_xml_file_when_structure_is_left_the_same(testCase)
            xml_existing_text = sprintf(['%s\n',...          
            '<global_tag>\n',...
            '   <child_element name="existing_child">\n',...
            '      Hola\n',...
            '      <granchild/>\n',...
            '      <element tag="Cold Approach">1</element>\n',...
            '      <element tag="Ejercicio">0</element>\n',...
            '      <element tag="Gratitud y Evidence Log">0</element>\n',...
            '   </child_element>\n',...
            '</global_tag>'], XmlTools_tests.xml_file_heading);
            f = fopen(XmlTools_tests.test_xml_file_name, 'w');
            fwrite(f, xml_existing_text);
            fclose(f);

            % When
            structure = XmlTools.xml2structure(XmlTools_tests.test_xml_file_name);
            XmlTools.structure2XML(structure, XmlTools_tests.test_xml_file_name);
            
            % Then
            xml_text = fileread(XmlTools_tests.test_xml_file_name);
            testCase.assertEqual(xml_text, xml_existing_text);
        end

        function should_convert_xml_to_structure(testCase)
            % Given
            xml_text = ['<global>', newline,...
            '<child attribute1=''value1'' attribute2=''value2''><grandchild/></child>', newline,...
            '<child attribute1=''value3'' attribute3=''value4''>Hola</child>', newline,...
            '</global>'];

            f = fopen(XmlTools_tests.test_xml_file_name, 'w');
            fwrite(f, xml_text);
            fclose(f);
            
            expected_structure = XmlTools_tests.generateXmlEmptyStructure();
            expected_structure.Tag = 'global';
            children = XmlTools_tests.generateXmlEmptyStructure(2);
            
            children(1).Tag = 'child';
            children(1).Attributes = XmlTools_tests.generateAttributeEmptyStructure(2);
            children(1).Attributes(1).Name = 'attribute1';
            children(1).Attributes(1).Value = 'value1';
            children(1).Attributes(2).Name = 'attribute2';
            children(1).Attributes(2).Value = 'value2';
            children(1).Children = XmlTools_tests.generateXmlEmptyStructure();
            children(1).Children.Tag = 'grandchild';
            
            children(2).Tag = 'child';
            children(2).Attributes = XmlTools_tests.generateAttributeEmptyStructure(2);
            children(2).Attributes(1).Name = 'attribute1';
            children(2).Attributes(1).Value = 'value3';
            children(2).Attributes(2).Name = 'attribute3';
            children(2).Attributes(2).Value = 'value4';
            children(2).Children = XmlTools_tests.generateXmlEmptyStructure();
            children(2).Children.Tag = '#text';
            children(2).Children.Data = 'Hola';

            expected_structure.Children = children;

            % When
            structure = XmlTools.xml2structure(XmlTools_tests.test_xml_file_name);
            
            % Then
            testCase.assertEqual(structure, expected_structure);
        end
    end
    
end